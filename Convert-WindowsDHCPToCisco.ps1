#
# Convert-WindowsDHCPToCisco
#
# Version 1.0.0
#    Justin S. Cooksey  2021-02-28
#

#                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
# Convert an exclusion range from MSDHCP XML to Cisco CLI code
#

function Convert-Exclusion {
    param( $Range )

    return("ip dhcp excluded-address "+$Range.StartRange+" "+$Range.EndRange)
}

#
# Convert an DHCP Pool from MSDHCP XML to Cisco CLI code
#

function Convert-PoolName {
    param( [string]$poolName )

    $result = $poolName.Split('.')[0]
    $result = [string]$result.Replace(" ","-")
    $result = [string]$result.ToLower()

    return $result
}

#
# Convert an lease duration from MSDHCP XML to Cisco CLI code
#

function Convert-LeaseDuration {
    param( [string]$leaseDuration)

    $textReformat = $leaseDuration.Replace( ",",".")
    $seconds = ([TimeSpan]::Parse($textReformat)).TotalSeconds
    $days = [int]($seconds / 86400)
    $hours = [int]($seconds / 3600) % 24
    $minutes = [int]($seconds / 60) % 60
    $result = "lease " + [string]$days + " " + [string]$hours + " " + [string]$minutes
    return  $result
}

#
# Convert DHCP options from MSDHCP XML to Cisco CLI code
#

function Convert-DHCPOptions {
    param( $Options)

    $result = ""

    foreach($option in $Options) {
        switch($option.OptionId) {
            3   { $result = $result + "  default-router " + $option.Value + "`n"; break }
            4   { break }                                                           #Time Server, dont use
            6   { $result = $result + "  dns-server " + $option.Value + "`n"; break }
            15  { $result = $result + "  domain-name " + $option.Value + "`n"; break }
            42  { $result = $result + "  option 42 ip " + $option.Value + "`n"; break } # NTP Servers
            51  { break } #Lease time in seconds. Not Required
            66  { $result = $result + "  next-server " + $option.Value + "`n";break } #DAP TFTP Server to load boot config
            67  { $result = $result + "  bootfile " + $option.Value + "`n";break } #DAP Bootfile name see option 66                                          
            81  { break } #Client FQDN. Not Required
            161 { $result = $result + "  option 161 ip " + $option.Value + "`n"; break }
            162 { $result = $result + '  option 162 ascii "' + $option.Value + '"'  + "`n"; break }
            252 { $result = $result + '  option 252 ascii "' + $option.Value + '"' + "`n"; break }
            default { $result = $result + "*** Unknown Option " + $option.OptionId + " with Value of " + $option.Value + " ***" + "`n"}
        }
    }

    return  $result
}

#
# Convert a MAC Address from MSDHCP XML to Cisco CLI code
#

function Convert-MAC {
    param( [string]$msMAC)

    $result = ""

    $result = "01" + $msMac.Replace("-", "")
    $result = $result.Insert(4,'.')
    $result = $result.Insert(9,'.')
    $result = $result.Insert(14,'.')
    return $result
}

#
# Convert DHCP reservations from MSDHCP XML to Cisco CLI code
#

function Convert-Reservations {
    param( $Reservations, [string]$subnetMask, [string]$subnetOptions)

    $result = ""

    foreach($reservation in $Reservations) {
        $result = $result + "ip dhcp pool " + (Convert-PoolName -poolName $reservation.Name) + "`n"
        $result = $result + "  host " + $reservation.IPAddress + " " + $subnetMask + "`n"
        $result = $result + "  client-identifier " + (Convert-MAC -msMAC $reservation.ClientId) + "`n"
        $result = $result + $subnetOptions + "`n"
    }

    return  $result
}


#
# Priomary code to read XML file and output Cisco CLI code
#

$OldServer = Read-Host 'Enter the computer name of the DHCP server to export from: '
$xmlFile = $env:TEMP + "\DHCPExport.xml"
Export-DhcpServer -ComputerName $OldServer -File $exportFile

[XML]$fullDHCP = Get-Content $xmlFile
$allScopes = $fullDHCP.DHCPServer.IPv4.Scopes.Scope

$globalOptions = Convert-DHCPOptions -Options $fullDHCP.DHCPServer.IPv4.OptionValues.OptionValue

foreach($scope in $allScopes) {
    foreach($exclusionRange in $scope.ExclusionRanges.IPRange) {
        $result = Convert-Exclusion -Range $exclusionRange
        Write-Output -InputObject $result
    }
    Write-Output -InputObject $null

    Write-Output -InputObject ("ip dhcp pool " + (Convert-PoolName -poolName $scope.Name))
    Write-Output -InputObject ("  network " + $scope.ScopeId + " " + $scope.SubnetMask)
    Write-Output -InputObject ("  " + (Convert-LeaseDuration -leaseDuration $scope.LeaseDuration))
    Write-Output -InputObject ("  update dns both override")
    $subnetOptions = $globalOptions + (Convert-DHCPOptions -Options $scope.OptionValues.OptionValue)
    Write-Output -InputObject ($subnetOptions)

    Write-Output -InputObject (Convert-Reservations -Reservations $scope.Reservations.Reservation -subnetMask $scope.SubnetMask -subnetOptions $null)

}

<#
$array =@('0x10', '0x0A', '0x0A', '0xC0', '0xA8', '0xA9', '0xE7', '0x1C', '0xCB', '0x1C',
          '0x1C', '0x00', '0xC0', '0xA8', '0xA9', '0xF5', '0x18', '0xC0', '0xA8', '0x00',
          '0xC0', '0xA8', '0xA9', '0xE7')
#>
 
$array = @('0x10','0xc0','0xa8', '0xc0', '0xa8', '0x6e', '0x01','0x08', '0x0a', '0xc0', '0xa8', '0xa8', '0x05')

Write-Host $array

$strNetwork = ""
$atMask = $true

for($i=0; $i -lt $array.Length; $i++) {

    if($atMask) {
        $mask = [convert]::toint64($array[$i],16)
        
        if($mask -lt 9) { 
            $strNetwork = $strNetwork + [convert]::toint64($array[$i+1],16) + ".0.0.0"
            $i = $i + 1
        }
        elseif($mask -lt 17) { 
            $strNetwork = $strNetwork + [convert]::toint64($array[$i+1],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+2],16) + ".0.0"
            $i = $1 + 2
        }
        elseif($mask -lt 25)  { 
            $strNetwork = $strNetwork + [convert]::toint64($array[$i+1],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+2],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+3],16) + ".0"
            $i = $i + 3
        }
        elseif($mask -ge 25)  { 
            $strNetwork = $strNetwork + [convert]::toint64($array[$i+1],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+2],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+3],16)
            $strNetwork = $strNetwork + "." + [convert]::toint64($array[$i+4],16)
            $i = $i + 4
        }
        $strNetwork = $strNetwork + "/" + $mask
        
        $strRouter = ""
        $strRouter = $strRouter + [convert]::toint64($array[$i+1],16)
        $strRouter = $strRouter + "." + [convert]::toint64($array[$i+2],16)
        $strRouter = $strRouter + "." + [convert]::toint64($array[$i+3],16)
        $strRouter = $strRouter + "." + [convert]::toint64($array[$i+4],16)

        $i = $i + 4

        Write-Host($strNetwork + " " + $strRouter)

        $mask = $true
        $strNetwork = ""

    }
    
}

#
# Mask is
#   m < 9   (8)     1 octet 
#   m < 17  (16)    2 octets
#   m < 25  (24)    3 octets
#                   4 octets

#
# option 121 hex 10c0a8c0a86e01 080AC0A8A805
# Written from Cisco as
#  option 121 hex 10c0.a8c0.a86e.0108.0ac0.a8a8.05

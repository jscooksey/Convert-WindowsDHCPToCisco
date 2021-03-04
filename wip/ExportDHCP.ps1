#Run this PowerShell Script on New DHCP Server
# Install-WindowsFeature DHCP
$OldServer ="NLDC"
$exportFile = $env:TEMP + "\DHCPExport.xml"
Export-DhcpServer -ComputerName $OldServer -File $exportFile

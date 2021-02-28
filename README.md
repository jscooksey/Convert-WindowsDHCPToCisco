# Convert Windows DHCP to Cisco CLI

## Version 1.0.0

### Justin S. Cooksey  - 2021-02-28

Script to export DHCP from a Windows Server DHCP database (exports to XML) and then convert the scope options and static leases to Cisco CLI to configure a router to take over the DHCP role on the network.

## Usage

``` Powershell
Convert-WindowsDHCPToCisco
```

* It will ask for the DHCP host servername.
* It will require to have administrtor privilegde to be able to export the DHCP scopes.
* Working files are stored under the current %TEMP% path
* Output file is stored in the execution path.

## DHCP Options Documentation

[Wikipedia DHCP Options table](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol#Client_configuration_parameters)
[Actual RFC2312](https://tools.ietf.org/html/rfc2132)

## Currently handles DHCP Options

| Code  | Option Description        | Cisco Output     |
|-------|---------------------------|------------------|
| 3     | Default Gateway           | default-router
| 4     | Time Server               | *ignoring*
| 6     | Domain Nameserver         | dns-server
| 15    | Domain Name               | domain-name
| 42    | NTP Servers               | option 42 ip
| 51    | Lease time                | *ignoring*
| 66    | TFTP Server               | next-server
| 67    | Boot filename             | bootfile
| 81    | MS DHCP Name Protection   | *ignoring*
| 161   | FTP Server                | option 161 ip
| 162   | Path                      | option 162 ascii
| 252   | Proxy PAC URL             | option 252 asicc

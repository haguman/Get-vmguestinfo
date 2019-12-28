$filepath = "E:\output\"
$filename ="vmguestinfo_" + (Get-Date).ToString().Replace(" ","T").Replace(":",".") + "_" + (whoami).replace("\",".")
$credential = Get-Credential

#region VMWare
$ErrorView = "CategoryView"
$vcenters2connect = "viserver1","viserver2"
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode Multiple
Connect-VIServer -Server $vcenters2connect -Credential $credential  -WarningAction Ignore | Out-Null
$vmguests = Get-View -ViewType VirtualMachine | select -ExpandProperty Guest | select GuestFullName, HostName, ToolsStatus, ToolsVersion, IpAddress , IpStack , Net, Disk,GuestState
$vmguestsreport = @()
foreach($vmguest in $vmguests)
{
            $properties  = @{
                            vmguest_VM = $vmguest.VM -join " | "
                            vmguest_GuestFullName = $vmguest.GuestFullName -join " | "
                            vmguest_HostName = $vmguest.HostName -join " | "
                            vmguest_ToolsStatus = $vmguest.ToolsStatus -join " | "
                            vmguest_ToolsVersion = $vmguest.ToolsVersion -join " | "
                            vmguest_IpAddress = $vmguest.IpAddress -join " | "
                            vmguest_IpStack = $vmguest.IpStack -join " | "
                            vmguest_IpStack_DNS = $vmguest.IpStack.dnsconfig.IpAddress -join " | "
                            vmguest_IpStack_DHCP = $vmguest.IpStack.dnsconfig.Dhcp -join " | "
                            vmguest_Net_NETWORK = $vmguest.Net.network -join " | "
                            vmguest_Net_Connected = $vmguest.Net.Connected -join " | "
                            vmguest_Net_MacAddress = $vmguest.Net.MacAddress -join " | "
                            vmguest_Net_IPAddress =  $vmguest.net.ipconfig.IpAddress.ipaddress -join " | "
                            vmguest_Disk = ($vmguest.Disk.diskpath | sort) -join " | "
                            }
            $object = New-Object -TypeName PSObject -Property $properties
            $vmguestsreport += $object
}
$global:DefaultVIServers.ForEach({Disconnect-VIServer -Server $_.name -Confirm:$false})
$vmguestsreport | Export-excel ($filepath + $filename + ".xlsx") -NoNumberConversion $true
$vmguestsreport | Export-Csv ($filepath + $filename + ".csv") -NoClobber -NoTypeInformation -Delimiter ";"

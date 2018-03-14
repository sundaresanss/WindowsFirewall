<#
    ##Example parameter
    $ProxyServers = '2a02:cc9:7732:5500::1','fd4e:eaa9:897b::1','172.19.110.1'
    Get-WindowsFeature -Name GPMC
#>

$SourceGPOBackupId = '{eb8aa8ac-840c-4e15-9ea4-dab25d6cb3a5}'
$TargetGPOName = 'SN-Domain Firewall Baseline'
$PathToGPOBackups = 'C:\Temp\SN-GPO'
$DomainName = $env:USERDNSDOMAIN
# Version 0.7.0 domain resources
$DomainControllers = '127.0.0.1','SERVERNAME'
$ProxyServerPorts = '8080'
$ProxyServers = 'LocalSubnet','Intranet'
$DNSServers = $DomainControllers
$CRLServers = 'LocalSubnet','Intranet'
$WPAD_PACFileServers = 'LocalSubnet','Intranet'
$TierXManagementServers = 'LocalSubnet','Intranet'
$SQLServers = '127.0.0.4'
$WebServers = 'LocalSubnet','Intranet'
$FileServers = 'LocalSubnet','Intranet'
$KeyManagementServers = 'LocalSubnet','Intranet'
$BackupServers = '127.0.0.1'
$ClusteredNodesAndManagementAddresses = 'LocalSubnet','Intranet'
$ExternalVPNEndpoints = '127.0.0.2 -  127.0.0.3' # This is not Direct Access it's IPSec
$DirectAccessServers = '127.0.0.128/25' # This is the externally resolvable address
$TrustedDHCPSubnets = 'Any' # This is enterprise subnets and includes subnets issued by the VPN server, 'Predefnied set of computers' cannot be used here
# END of version 0.7.0 domain resources

$Resources = 'DomainControllers','ProxyServers','DNSServers','CRLServers','WPAD_PACFileServers','TierXManagementServers','SQLServers','WebServers','FileServers','KeyManagementServers','BackupServers','ClusteredNodesAndManagementAddresses','ExternalVPNEndpoints','DirectAccessServers','TrustedDHCPSubnets'

function AttemptResolveDNSNAME ($Name)
{
    try
    {
        $Addresses += (Resolve-DnsName $Name -ErrorAction Stop).IPAddress
    }
    catch
    {
        Write-warning "The hostname $Name could not be resolved, check connectivity to the DNS infrastructure and ensure there is a valid host record for $Name."
    }
}

if (!(Test-Path "$PathToGPOBackups\manifest.xml" -ErrorAction SilentlyContinue))
{
    Write-Warning "The GPO backups cannot be found, please ensure the backup zip file has been downloaded and extracted to $PathToGPOBackups"
    break
}

foreach ($Resource in $Resources)
{
    $Addresses = @()
    $Names = (Get-Variable -Name $Resource).Value
    foreach ($Name in $Names.replace(" ",""))
    {
        switch -Wildcard ($Name)
        {
            "*/*"           {
                                $Addresses += $Name
                                break
                            }
            "LocalSubnet"   {
                                $Addresses += $Name
                                break
                            }
            "Intranet"      {
                                $Addresses += $Name
                                break
                            }
            "DNS"           {
                                $Addresses += $Name
                                break
                            }
            "DHCP"          {
                                $Addresses += $Name
                                break
                            }
            "DefaultGateway"{
                                $Addresses += $Name
                                break
                            }
            "Internet"      {
                                $Addresses += $Name
                                break
                            }
            "Any"           {
                                $Addresses += $Name
                                break
                            }
            "*-*"           {
                                try
                                {
                                    if ([ipaddress]$Name.Split("-")[0] -and [ipaddress]$Name.Split("-")[1])
                                    {
                                        $Addresses += $Name
                                    }
                                }
                                catch [Management.Automation.PSInvalidCastException]
                                {
                                    AttemptResolveDNSNAME $Name

                                }
                            }
            default         {
                                try
                                {
                                    if ([ipaddress]$Name)
                                    {
                                        $Addresses += $Name
                                    }
                                }
                                catch [Management.Automation.PSInvalidCastException]
                                {
                                    AttemptResolveDNSNAME $Name
                                }
                            }
        }
    }
    Set-Variable -Name $Resource -Value $Addresses
}

if (!(Get-GPO -DisplayName $TargetGPOName  -ErrorAction SilentlyContinue))
{
    Import-GPO -BackupId $SourceGPOBackupId -Path $PathToGPOBackups -TargetName $TargetGPOName -CreateIfNeeded -ErrorAction Stop
    $InboundBackupServers = 
    '{C245295B-F872-4582-8D46-4D16FC51C59C}'

    $OutboundProxyServersRules = 
    '{25C5B199-A7D0-47F0-9FE9-DB865ED8F81E}',
    '{C3C97E3E-8B01-43E7-BD74-4ED58078EB5F}',
    '{8283667D-A196-4B01-8D72-9F29216FF662}',
    '{DC50E65E-F97A-4732-B105-5C501923B34B}',
    '{487682B5-C30A-4137-8086-C2815809706A}',
    '{F045E216-AA87-4FAB-A5B5-E17A0DB06DA5}',
    '{529CF5BF-C0F7-4937-AF50-BDEE125792EB}',
    '{021B839E-B818-446C-BC2F-8B58D371E609}',
    '{8CDFE99B-E2E5-417A-9166-B5BDF815C19E}',
    '{AC498E56-C4D3-4006-B0EA-7F8781BEDCE5}',
    '{71A9E996-5EB1-4A2B-B69A-81216B149B1A}',
    '{3CDDA904-F0F1-4889-A9B3-FDC2A4A52EF8}',
    '{9671EB76-EEE2-4A48-A25B-FCB62D0C68CD}',
    '{3557218E-C9B3-4398-B0E0-BC3FA10DB76C}',
    '{9DA4A1C8-E145-4D70-98F4-236A90DB53D7}',
    '{24640B17-6FC7-4E4C-A6ED-ECDDD6DE9D5B}',
    '{64B3B85A-4716-4F83-A77B-5FE3487B80ED}',
    '{C3DDF046-BB17-4F73-825A-D5AEB9125BE9}',
    '{268553D7-EB7B-4003-8158-22AF750240FD}',
    '{1B3D771D-0D1D-4247-BA97-19357648C439}',
    '{86001CC7-7554-49DE-9F47-023540B9FD0C}',
    '{CFD89AD8-AE18-412C-9E4F-24E8B39801FD}',
    '{EAAC634E-2E0F-43D3-A104-02A4C4543EBB}',
    '{E6FDD82B-6B1A-4CB9-82FB-74AB232F1D39}',
    '{FE79F702-5E3F-4498-909B-C2B78C0A8D4A}',
    '{4D66D753-FEAB-470E-975F-C2789912132F}',
    '{6F74C19E-8B01-4A3F-9D6E-3DD629CE138D}',
    '{72F7F255-42DA-4BE0-BAC4-7168798D1731}',
    '{305D7555-6BDF-42AF-8CCD-BA50748642BF}',
    '{FDA7F3F5-D1F9-4A1B-9F11-2427A4325FEC}',
    '{AC2E7A6D-32E7-46E3-AC3C-D945B9CA4926}',
    '{9F866747-18B8-4539-B7A4-CBFAC941AA41}',
    '{8571CCC3-5D33-46B2-B046-D91895C51BEF}'
              
    $OutboundDomainControllersRules = 
    '{667F71F3-512A-4004-832F-37A1F04E8B37}',
    '{E5102F82-3E96-43A1-A594-0ED82B5946B3}',
    '{A2E68AF0-EAC7-4AAF-A337-821AB4100AF2}',
    '{87FC29B6-C496-415A-AA86-806E2E1910D4}',
    '{88205410-9317-4AD3-9FA7-EAEBF0B9D6E5}',
    '{FA542913-DECD-4F46-86E1-9108CC3B9404}',
    '{D5BF897C-86AA-4D24-808D-27CE7ADF9ECF}',
    '{6A7837C1-5283-4430-94B3-9B4D02119703}',
    '{EAC8E3B5-5C94-4F18-AAD7-B8FC2DA847FE}'
    
    $OutboundKeyManagementServersRules = 
    '{7A3D1F5E-89CE-4226-B73F-8243F3002634}'

    $OutboundCRLServersRules = 
    '{9EFABED8-AEB9-47CD-8D28-FFE914769085}',
    '{22F125A5-55A4-4146-852E-641179E2AD3B}'
    
    $GPOSession = Open-NetGPO -PolicyStore "$DomainName\$TargetGPOName"
    foreach ($InboundBackupServer in $InboundBackupServers)
    {
        Set-NetFirewallRule -Name $InboundBackupServer -GPOSession $GPOSession -RemoteAddress $BackupServers
    }
    foreach ($OutboundProxyServersRule in $OutboundProxyServersRules)
    {
        Set-NetFirewallRule -Name $OutboundProxyServersRule -GPOSession $GPOSession -RemoteAddress $ProxyServers -RemotePort $ProxyServerPorts
    }
    foreach ($OutboundDomainControllersRule in $OutboundDomainControllersRules)
    {
        Set-NetFirewallRule -Name $OutboundDomainControllersRule -GPOSession $GPOSession -RemoteAddress $DomainControllers
    }
    foreach ($OutboundKeyManagementServersRule in $OutboundKeyManagementServersRules)
    {
        Set-NetFirewallRule -Name $OutboundKeyManagementServersRule -GPOSession $GPOSession -RemoteAddress $KeyManagementServers
    }
    foreach ($OutboundCRLServersRule in $OutboundCRLServersRules)
    {
        Set-NetFirewallRule -Name $OutboundCRLServersRule -GPOSession $GPOSession -RemoteAddress $CRLServers
    }
    Save-NetGPO -GPOSession $GPOSession
}
else
{
    Write-Warning "The policy `"$TargetGPOName`" already exists and no updates are available for this baseline"
}

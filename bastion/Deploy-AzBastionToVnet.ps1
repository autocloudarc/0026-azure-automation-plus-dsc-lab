# https://docs.microsoft.com/en-us/azure/bastion/bastion-create-host-powershell

#region Get Existing Vnet Info
$vnet = New-AzVirtualNetwork -Name "myVnet" -ResourceGroupName "myBastionRG" -Location "westeurope" -AddressPrefix 10.0.0.0/16 -Subnet $subnet
#endregion

#region Check for jump server candidate machines
# This server will be flagged as a possible Jump server and public IP will be removed after bastion is deployed.
#endregion

#region Create bastion subnet
$subnetName = "AzureBastionSubnet"
$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
#endregion

#region Update Vnet with bastion subnet
#endregion

#region Create bastion public IP
$publicip = New-AzPublicIpAddress -ResourceGroupName "myBastionRG" -name "myPublicIP" -location "westeurope" -AllocationMethod Static -Sku Standard
#endregion

#region Create NSG rules for bastion subnet
    # INGRESS
    # Ingress traffic from public Internet
    $basNsgRule443FromInternetRuleName = "Allow443FromInternet"
    $basNsgRule443FromInternet = New-AzNetworkSecurityRuleConfig -Name $basNsgRule443FromInternetRuleName `
    -Description  $basNsgRule443FromInternetRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 443
    # Ingress traffic tfrom Azure Bastion control pane
    $basNsgRule443FromGatewayManagerRuleName = "Allow443FromGatewayManager"
    $basNsgRule443FromGatewayManager = New-AzNetworkSecurityRuleConfig -Name $basNsgRule443FromGatewayManagerRuleName `
    -Description  $basNsgRule443FromGatewayManagerRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix GatewayManager `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 443,4443

    # EGRESS
    # To AzureCloud
    $allowAzureServicesRuleName = "AllowAzureServices"
    $allowAzureServices = New-AzNetworkSecurityRuleConfig -Name $allowAzureServicesRuleName `
    -Description  "AllowAzureServices" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Outbound `
    -Priority 120 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix AzureCloud `
    -DestinationPortRange 443
    # To VirtualNetwork
    $allowRemoteToVirtualNetworkRuleName = "AllowRemoteToVirtualNetwork"
    $allowRemoteToVirtualNetwork = New-AzNetworkSecurityRuleConfig -Name $allowRemoteToVirtualNetworkRuleName `
    -Description  $allowRemoteToVirtualNetworkRuleName `
    -Access Allow `
    -Protocol Tcp `
    -Direction Outbound `
    -Priority 130 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 3389,22
#endregion

#region Create bastion NSG
$basNsg = New-AzNetworkSecurityGroup -Name $nsgBasName -ResourceGroupName $rg -Location $region -SecurityRules $basNsgRule443FromInternet,$basNsgRule443FromGatewayManager,$allowRemoteToVirtualNetwork,$allowAzureServices -Verbose
#endregion

#region Check for NSGs and add rules for non-bastion subnets
# Check for NSGs
# Add bastion rules
#endregion

#region Create bastion host
$bastion = New-AzBastion -ResourceGroupName "myBastionRG" -Name "myBastion" -PublicIpAddress $publicip -VirtualNetwork $vnet
#endregion

#region Confirm bastion deployment and remove public IP
#endregion
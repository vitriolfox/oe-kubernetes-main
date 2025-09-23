$file_content = Get-Content "./.secret" -raw
$file_content = [Regex]::Escape($file_content)
$file_content = $file_content -replace "(\\r)?\\n", [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)



$subscription = $configuration.'subscriptionId'
$dnsZoneName = 'oedevops.site'
$dnsSubscriptionId = $configuration.'dnsSubscriptionId'
$dnsZoneRg = 'rg-dns'
$dnsVmPrefix = 'vm'
$resourceGroup = 'oe-docker-rg'
$vmName = 'oe-docker-vm'
$vmSize= 'Standard_DS1_v2'  #Standard_DS1_v2 Standard_D2as_v4
$adminUser = 'azureadm'
$adminPwd = $configuration.'vmAdminPassword'
$vnet = 'oe-docker-vnet'
$subnet = 'subnet-1'
$count = 2
$createAks = $true
$aksName= 'oe-kubernetes-aks'
$kubeconfigFileName = ".kubeconfig"


az account set --subscription $subscription


az group create --location westeurope --resource-group $resourceGroup

if( $createAks ){
    az aks create -g $resourceGroup  `
    -n $aksName `
    --enable-managed-identity  `
    --node-count 1  `
    --vm-set-type VirtualMachineScaleSets `
    --load-balancer-sku standard `
    --enable-cluster-autoscaler `
    --min-count 1 `
    --max-count 3

    # save kubeconfig
    if (Test-Path $kubeconfigFileName) {
        Remove-Item $kubeconfigFileName
    }
    az aks get-credentials --resource-group $resourceGroup --name $aksName --file $kubeconfigFileName
    # TODO: put the kubeconfig to the vm pscp 22 port is blocked on my laptop

}

az network vnet create `
    --name oe-docker-vnet `
    --resource-group $resourceGroup `
    --address-prefix 10.0.0.0/16 `
    --subnet-name subnet-1 `
    --subnet-prefixes 10.0.0.0/24

az vm create `
    --resource-group $resourceGroup `
    --name $vmName `
    --image Ubuntu2204  `
    --public-ip-sku Standard `
    --admin-username $adminUser `
    --admin-password $adminPwd `
    --vnet-name $vnet `
    --subnet $subnet `
    --size $vmSize `
    --count $count

# set up the VMs
for ($i = 0; $i -lt $count; $i++) {
    $vm = "$vmName$i"
    # install dependencies
    az vm extension set `
        --resource-group $resourceGroup `
        --vm-name $vm  --name customScript `
        --publisher Microsoft.Azure.Extensions `
        --version 2.0 `
        --settings ./iac/custom-script-config.json
    # set autoshutdown
    az vm auto-shutdown -n $vm -g $resourceGroup --time 1730

    # open ports
    az vm open-port -n $vm -g $resourceGroup --port 80,8080
    
}

$publiciplist=$(az vm list-ip-addresses -g $resourceGroup  --query "[].virtualMachine.network.publicIpAddresses[0].id" -o tsv)
$counter = 0
az account set --subscription $dnsSubscriptionId
foreach ($ipResource in $publiciplist) {
  $arec = "$dnsVmPrefix$counter"
  # delete if exists
  az network dns record-set a delete -g $dnsZoneRg  -z $dnsZoneName -n $arec --yes
  # create
  az network dns record-set a create -g $dnsZoneRg -n $arec -z $dnsZoneName --target-resource $ipResource
  $counter++
}

az account set --subscription $subscription
# az group delete --resource-group $resourceGroup --yes

# workaround to put kubeconfig from cloudshell
# for i in $(seq 0 1); do scp -pr -o StrictHostKeyChecking=no .kube azureadm@vm$i.oedevops.site:~; done

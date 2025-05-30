targetScope = 'subscription'

param location string
param workloadName string = 'nsp'
param environment string = 'demo'
param instance int = 1
param namingConvention string = '{workloadName}-{subWorkloadName}-{env}-{rtype}-{loc}-{seq}'
param tags object = {
  purpose: 'ACC2025'
}
param databaseAdminUpn string = 'sven@aelterman.cloud'
param allowInboundIpAddresses string[] = []

param deployNsp bool = false
param associateNsp bool = false
param resourceAccessMode ('Learning' | 'Enforced' | 'Audit') = 'Learning'

var instanceFormatted = format('{0:00}', instance)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${workloadName}-${environment}-rg-${shortLocations[location]}-${instanceFormatted}'
  location: location
  tags: tags
}

module resourcesModule 'resources.bicep' = {
  name: 'resourcesDeployment'
  scope: resourceGroup
  params: {
    location: location
    workloadName: workloadName
    environment: environment
    instance: instance
    namingConvention: namingConvention
    tags: tags
    databaseAdminUpn: databaseAdminUpn
    allowInboundIpAddresses: allowInboundIpAddresses

    deployNsp: deployNsp
    associateNsp: associateNsp
    resourceAccessMode: resourceAccessMode
  }
}

var shortLocations = {
  australiacentral: 'acl'
  'Australia Central': 'acl'
  australiacentral2: 'acl2'
  'Australia Central 2': 'acl2'
  australiaeast: 'ae'
  'Australia East': 'ae'
  australiasoutheast: 'ase'
  'Australia Southeast': 'ase'
  brazilsouth: 'brs'
  'Brazil South': 'brs'
  brazilsoutheast: 'bse'
  'Brazil Southeast': 'bse'
  centraluseuap: 'ccy'
  'Central US EUAP': 'ccy'
  canadacentral: 'cnc'
  'Canada Central': 'cnc'
  canadaeast: 'cne'
  'Canada East': 'cne'
  centralus: 'cus'
  'Central US': 'cus'
  eastasia: 'ea'
  'East Asia': 'ea'
  eastus2euap: 'ecy'
  'East US 2 EUAP': 'ecy'
  eastus: 'eus'
  'East US': 'eus'
  eastus2: 'eus2'
  'East US 2': 'eus2'
  francecentral: 'frc'
  'France Central': 'frc'
  francesouth: 'frs'
  'France South': 'frs'
  germanynorth: 'gn'
  'Germany North': 'gn'
  germanywestcentral: 'gwc'
  'Germany West Central': 'gwc'
  centralindia: 'inc'
  'Central India': 'inc'
  southindia: 'ins'
  'South India': 'ins'
  westindia: 'inw'
  'West India': 'inw'
  italynorth: 'itn'
  'Italy North': 'itn'
  japaneast: 'jpe'
  'Japan East': 'jpe'
  japanwest: 'jpw'
  'Japan West': 'jpw'
  jioindiacentral: 'jic'
  'Jio India Central': 'jic'
  jioindiawest: 'jiw'
  'Jio India West': 'jiw'
  koreacentral: 'krc'
  'Korea Central': 'krc'
  koreasouth: 'krs'
  'Korea South': 'krs'
  northcentralus: 'ncus'
  'North Central US': 'ncus'
  northeurope: 'ne'
  'North Europe': 'ne'
  norwayeast: 'nwe'
  'Norway East': 'nwe'
  norwaywest: 'nww'
  'Norway West': 'nww'
  qatarcentral: 'qac'
  'Qatar Central': 'qac'
  southafricanorth: 'san'
  'South Africa North': 'san'
  southafricawest: 'saw'
  'South Africa West': 'saw'
  southcentralus: 'scus'
  'South Central US': 'scus'
  swedencentral: 'sdc'
  'Sweden Central': 'sdc'
  swedensouth: 'sds'
  'Sweden South': 'sds'
  southeastasia: 'sea'
  'Southeast Asia': 'sea'
  switzerlandnorth: 'szn'
  'Switzerland North': 'szn'
  switzerlandwest: 'szw'
  'Switzerland West': 'szw'
  uaecentral: 'uac'
  'UAE Central': 'uac'
  uaenorth: 'uan'
  'UAE North': 'uan'
  uksouth: 'uks'
  'UK South': 'uks'
  ukwest: 'ukw'
  'UK West': 'ukw'
  westcentralus: 'wcus'
  'West Central US': 'wcus'
  westeurope: 'we'
  'West Europe': 'we'
  westus: 'wus'
  'West US': 'wus'
  westus2: 'wus2'
  'West US 2': 'wus2'
  westus3: 'wus3'
  'West US 3': 'wus3'
  usdodcentral: 'udc'
  'USDoD Central': 'udc'
  usdodeast: 'ude'
  'USDoD East': 'ude'
  usgovarizona: 'uga'
  'USGov Arizona': 'uga'
  usgoviowa: 'ugi'
  'USGov Iowa': 'ugi'
  usgovtexas: 'ugt'
  'USGov Texas': 'ugt'
  usgovvirginia: 'ugv'
  'USGov Virginia': 'ugv'
  usnateast: 'exe'
  'USNat East': 'exe'
  usnatwest: 'exw'
  'USNat West': 'exw'
  usseceast: 'rxe'
  'USSec East': 'rxe'
  ussecwest: 'rxw'
  'USSec West': 'rxw'
  chinanorth: 'bjb'
  'China North': 'bjb'
  chinanorth2: 'bjb2'
  'China North 2': 'bjb2'
  chinanorth3: 'bjb3'
  'China North 3': 'bjb3'
  chinaeast: 'sha'
  'China East': 'sha'
  chinaeast2: 'sha2'
  'China East 2': 'sha2'
  chinaeast3: 'sha3'
  'China East 3': 'sha3'
  germanycentral: 'gec'
  'Germany Central': 'gec'
  germanynortheast: 'gne'
  'Germany North East': 'gne'
}

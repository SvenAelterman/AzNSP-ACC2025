param location string = 'canadacentral'
param workloadName string = 'nsp'
param environment string = 'demo'
param instance int = 1
param namingConvention string = '{workloadName}-{subWorkloadName}-{env}-{rtype}-{loc}-{seq}'
param tags object = {
  purpose: 'ACC2025'
}
param databaseAdminUpn string = 'sven@aelterman.cloud'

#disable-next-line no-unused-params
param useNetworkSecurityPerimeter bool = false

var keyName = 'AzureSqlTdeRSA'

// Deploy Log Analytics Workspace
module logAnalyticsModule 'br/public:avm/res/operational-insights/workspace:0.11.1' = {
  name: 'workspaceDeployment'
  params: {
    name: logAnalyticsNameModule.outputs.validName

    dailyQuotaGb: 1

    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'

    tags: tags
    enableTelemetry: false
  }
}

module sqlServerModule 'br/public:avm/res/sql/server:0.15.1' = {
  name: 'sqlServerDeployment'
  params: {
    name: sqlNameModule.outputs.validName
    location: location

    administrators: {
      azureADOnlyAuthentication: true
      login: databaseAdminUser.userPrincipalName
      principalType: 'User'
      sid: databaseAdminUser.id
      tenantId: subscription().tenantId
    }
    customerManagedKey: {
      autoRotationEnabled: true
      keyName: keyName
      keyVaultResourceId: keyVaultModule.outputs.resourceId
      keyVersion: split(keyVaultModule.outputs.keys[0].uriWithVersion, '/')[5]
    }

    databases: [
      {
        collation: 'Latin1_General_100_CI_AS_SC_UTF8'
        diagnosticSettings: [
          {
            workspaceResourceId: logAnalyticsModule.outputs.resourceId
          }
        ]
        licenseType: 'LicenseIncluded'
        maxSizeBytes: 5368709120
        name: 'sampledb'
        sku: {
          name: 'S0'
          tier: 'Standard'
        }
        zoneRedundant: false
      }
    ]

    managedIdentities: {
      systemAssigned: false
      userAssignedResourceIds: [
        idModule.outputs.resourceId
      ]
    }
    primaryUserAssignedIdentityId: idModule.outputs.resourceId

    tags: tags
    enableTelemetry: false
  }
}

// Deploy Key Vault and an encryption key
module keyVaultModule 'br/public:avm/res/key-vault/vault:0.12.1' = {
  name: 'keyVaultDeployment'
  params: {
    name: keyVaultNameModule.outputs.validName
    location: location

    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsModule.outputs.resourceId
      }
    ]

    enablePurgeProtection: true
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 7

    roleAssignments: [
      {
        principalId: idModule.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Key Vault Crypto Service Encryption User'
      }
      {
        principalId: deployer().objectId
        principalType: 'User'
        roleDefinitionIdOrName: 'Key Vault Administrator'
      }
    ]

    keys: [
      {
        attributes: {
          enabled: true
        }
        keySize: 3072
        name: keyName
        kty: 'RSA'
        rotationPolicy: {
          attributes: {
            expiryTime: 'P1Y'
          }
          lifetimeActions: [
            {
              action: {
                type: 'Rotate'
              }
              trigger: {
                timeBeforeExpiry: 'P2M'
              }
            }
            {
              action: {
                type: 'Notify'
              }
              trigger: {
                timeBeforeExpiry: 'P30D'
              }
            }
          ]
        }
      }
    ]

    lock: {
      kind: 'CanNotDelete'
      name: '${keyVaultNameModule.outputs.validName}-lock'
    }

    tags: tags
    enableTelemetry: false
  }
}

// TODO: Optionally, deploy and configure Network Security Perimeter

// Deploy UAMI to support accessing the Key Vault by the SQL DB
module idModule 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'userAssignedIdentityDeployment'
  params: {
    name: idNameModule.outputs.validName

    location: location
    lock: {
      kind: 'CanNotDelete'
      name: '${idNameModule.outputs.validName}-lock'
    }
    tags: tags
    enableTelemetry: false
  }
}

output keyVaultName string = keyVaultNameModule.outputs.validName
output logAnalyticsWorkspaceName string = logAnalyticsNameModule.outputs.validName

module keyVaultNameModule 'common-modules/createValidAzResourceName.bicep' = {
  name: 'keyVaultNameDeployment'
  params: {
    location: location
    environment: environment
    namingConvention: namingConvention
    resourceType: 'kv'
    sequence: instance
    workloadName: workloadName
    alwaysUseShortLocation: true
  }
}

module logAnalyticsNameModule 'common-modules/createValidAzResourceName.bicep' = {
  params: {
    location: location
    environment: environment
    namingConvention: namingConvention
    resourceType: 'log'
    sequence: instance
    workloadName: workloadName
    alwaysUseShortLocation: true
  }
}

module idNameModule 'common-modules/createValidAzResourceName.bicep' = {
  name: 'idNameDeployment'
  params: {
    location: location
    environment: environment
    namingConvention: namingConvention
    resourceType: 'id'
    sequence: instance
    workloadName: workloadName
    alwaysUseShortLocation: true
  }
}

module sqlNameModule 'common-modules/createValidAzResourceName.bicep' = {
  name: 'sqlNameDeployment'
  params: {
    location: location
    environment: environment
    namingConvention: namingConvention
    resourceType: 'sql'
    sequence: instance
    workloadName: workloadName
    alwaysUseShortLocation: true
  }
}

extension graphV1
resource databaseAdminUser 'Microsoft.Graph/users@v1.0' existing = {
  userPrincipalName: databaseAdminUpn
}

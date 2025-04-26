param location string = resourceGroup().location
param nspName string
param allowInboundIpAddresses string[] = []
param associationResourceIds string[] = []
param tags object = {}
param logAnalyticsWorkspaceId string

var profileName = 'EncryptionProfile'
var inboundIpv4AccessRuleName = 'InboundAccessRule'

resource networkSecurityPerimeter 'Microsoft.Network/networkSecurityPerimeters@2024-06-01-preview' = {
  name: nspName
  location: location
  properties: {}
  tags: tags
}

resource profile 'Microsoft.Network/networkSecurityPerimeters/profiles@2024-06-01-preview' = {
  parent: networkSecurityPerimeter
  name: profileName
  location: location
  properties: {}
  tags: tags
}

resource inboundAccessRule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: profile
  name: inboundIpv4AccessRuleName
  location: location
  properties: {
    direction: 'Inbound'
    addressPrefixes: allowInboundIpAddresses
    fullyQualifiedDomainNames: []
    subscriptions: []
    emailAddresses: []
    phoneNumbers: []
  }
  tags: tags
}

// resource outboundAccessRule 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2023-07-01-preview' = {
//   parent: profile
//   name: outboundFqdnAccessRuleName
//   location: location
//   properties: {
//     direction: 'Outbound'
//     addressPrefixes: []
//     fullyQualifiedDomainNames: [
//       'contoso.com'
//     ]
//     subscriptions: []
//     emailAddresses: []
//     phoneNumbers: []
//   }
// }

resource resourceAssociations 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2024-06-01-preview' = [
  for associationResourceId in associationResourceIds: {
    parent: networkSecurityPerimeter
    name: '${nspName}-${guid(networkSecurityPerimeter.id, associationResourceId)}'
    location: location
    properties: {
      privateLinkResource: {
        #disable-next-line use-resource-id-functions
        id: associationResourceId
      }

      profile: {
        id: profile.id
      }

      accessMode: 'Learning'
    }
    tags: tags
  }
]

resource nspDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: networkSecurityPerimeter
  name: '${nspName}-diagnosticSetting'
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

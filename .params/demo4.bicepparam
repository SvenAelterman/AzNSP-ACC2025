using '../main.bicep'

param deployNsp = true
param associateNsp = true
param workloadName = 'nsp'
param resourceAccessMode = 'Enforced'

param instance = 40
param location = 'canadacentral'

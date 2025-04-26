using '../main.bicep'

param deployNsp = true
param associateNsp = true
param workloadName = 'nsp'
param resourceAccessMode = 'Learning'

param instance = 30
param location = 'canadacentral'

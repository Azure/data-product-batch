# Data Product Batch - Prerequisites

This template repository contains all templates to deploy a Data Product for batch data processing inside a Data Landing Zone of the Cloud-scale Analytics Scenario. Data Products are another unit of scale inside a Data Landing Zone and provide environments to cross-functional teams to work on individual data use-cases. This template can also be used for data integration into the platform. The fundamental difference would be that these teams are then connecting to data sources outside of the Data Landing Zones, which may requires the use of Self-hosted integration runtimes. Hence, this template qualifies for the following usage:

| Scenario         | Applicability      |
|:-----------------|:-------------------|
| Data Product     | :heavy_check_mark: |
| Data Integration | :heavy_check_mark: |

## What will be deployed?

By navigating through the deployment steps, you will deploy the following setup in a subscription:

> **Note:** Before deploying the resources, we recommend to check registration status of the required resource providers in your subscription. For more information, see [Resource providers for Azure services](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types).

![Data Product Batch](/docs/images/ProductBatch.png)

The deployment and code artifacts include the following services:

- [Key Vault](https://docs.microsoft.com/azure/key-vault/general)
- [Data Factory](https://docs.microsoft.com/azure/data-factory/) (select between Data Factory and Synapse)
- [Cosmos DB](https://docs.microsoft.com/azure/cosmos-db/introduction) (optional)
- [Synapse Workspace](https://docs.microsoft.com/azure/synapse-analytics/) (select between Data Factory and Synapse)
- [MySQL Database](https://docs.microsoft.com/azure/mysql/overview) (optional)
- [Azure SQL Database](https://docs.microsoft.com/azure/azure-sql/database/) (optional)
- [PostgreSQL Database](https://docs.microsoft.com/azure/postgresql/) (optional)
- [MariaDB Database](https://docs.microsoft.com/azure/mariadb/) (optional)
- [SQL Pool](https://docs.microsoft.com/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-overview-what-is) (optional)
- [SQL Server](https://docs.microsoft.com/sql/sql-server/?view=sql-server-ver15) (optional)
- [SQL Elastic Pool](https://docs.microsoft.com/azure/azure-sql/database/elastic-pool-overview) (optional)
- [BigData Pool](https://docs.microsoft.com/sql/big-data-cluster/concept-data-pool?view=sql-server-ver15)

## Code Structure

To help you more quickly understand the structure of the repository, here is an overview of what the respective folders contain:

| File/folder                   | Description                                |
| ----------------------------- | ------------------------------------------ |
| `.ado/workflows`              | Folder for ADO workflows. The `dataProductDeployment.yml` workflow shows the steps for an end-to-end deployment of the architecture. |
| `.github/workflows`           | Folder for GitHub workflows. The `dataProductDeployment.yml` workflow shows the steps for an end-to-end deployment of the architecture. |
| `code`                        | Sample password generation script that will be run in the deployment workflow for resources that require a password during the deployment. |
| `docs`                        | Resources for this README.                 |
| `infra`                       | Folder containing all the ARM and Bicep templates for each of the resources that will be deployed. |
| `CODE_OF_CONDUCT.md`          | Microsoft Open Source Code of Conduct.     |
| `LICENSE`                     | The license for the sample.                |
| `README.md`                   | This README file.                          |
| `SECURITY.md`                 | Microsoft Security README.                 |

## Supported Regions

For now, we are recommending to select one of the regions mentioned below. The list of regions is limited for now due to the fact that not all services and features are available in all regions. This is mostly related to the fact that we are recommending to leverage at least the zone-redundant storage replication option for all your central Data Lakes in the Data Landing Zones. Since zone-redundant storage is not available in all regions, we are limiting the regions in the Deploy to Azure experience. If you are planning to deploy the Data Management Landing Zone and Data Landing Zone to a region that is not listed below, then please change the setting in the corresponding bicep files in this repository. Deployment has been tested in the following regions:

- (Africa) South Africa North
- (Asia Pacific) Southeast Asia
- (Asia Pacific) Australia East
- (Asia Pacific) Central India
- (Asia Pacific) Japan East
- (Asia Pacific) Southeast Asia
- (Asia Pacific) South India
- (Canada) Canada Central
- (Europe) North Europe
- (Europe) West Europe
- (Europe) France Central
- (Europe) Germany West Central
- (Europe) North Europe
- (Europe) UK South
- (Europe) West Europe
- (South America) Brazil South
- (US) Central US
- (US) East US
- (US) East US 2
- (US) South Central US
- (US) West Central US
- (US) West US 2

**Please open a pull request if you want to deploy the artifacts into a region that is not listed above.**

## Prerequisites

> **Note:** Please make sure you have successfully deployed a [Data Management Landing Zone](https://github.com/Azure/data-management-zone) and a [Data Landing Zone](https://github.com/Azure/data-landing-zone) beforehand. Also, this template requires subnets as specified in the prerequisites. The Data Landing Zone already creates a few subnets, which can be used for this Data Product.

Before we start with the deployment, please make sure that you have the following available:

- A **Data Management Landing Zone** deployed. For more information, check the [Data Management Landing Zone](https://github.com/Azure/data-management-zone) repository.
- A **Data Landing Zone** deployed. For more information, check the [Data Landing Zone](https://github.com/Azure/data-landing-zone) repository.
- A resource group within an Azure subscription
- An Azure subscription. If you don't have an Azure subscription, [create your Azure free account today](https://azure.microsoft.com/free/).
- [User Access Administrator](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) or [Owner](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner) access to the subscription to be able to create a service principal and role assignments for it.
- Access to a subnet with `privateEndpointNetworkPolicies` and `privateLinkServiceNetworkPolicies` set to disabled. The Data Landing Zone deployment already creates a few subnets with this configuration (subnets with name `DataProduct00{x}Subnet` or `DataIntegration00{x}Subnet`.).
- For the deployment, please choose one of the **Supported Regions**.

## Deployment

Now you have two options for the deployment of the Data Landing Zone:

1. Deploy to Azure Button
2. GitHub Actions or Azure DevOps Pipelines

To use the Deploy to Azure Button, please click on the button below:

| Reference implementation   | Description | Deploy to Azure |
|:---------------------------|:------------|:----------------|
| Data Product Batch     | Deploys a Data Workload template for Data Batch Analysis to a resource group inside a Data Landing Zone. Please deploy a [Data Management Landing Zone](https://github.com/Azure/data-management-zone) and [Data Landing Zone](https://github.com/Azure/data-landing-zone) first. |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fdata-product-batch%2Fmain%2Finfra%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fdata-product-batch%2Fmain%2Fdocs%2Freference%2Fportal.dataProduct.json) | [Repository](https://github.com/Azure/data-product-batch) |

Alternatively, click on `Next` to follow the steps required to successfully deploy the Data Landing Zone through GitHub Actions or Azure DevOps.

>[Next](/docs/DataManagementAnalytics-CreateRepository.md)

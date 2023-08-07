SELECT
SubscriberKey,
Subscriberkey2,
Salutation,
FirstName,
LastName,
AccountName,
Emailadress,
AccountNumber,
BillingCountry,
BillingCity,
BillingPostalCode,
BillingStreet,
BillingHouseNo,
BillingFlatNo,
BillingFloor,
PrefLanguage,
SR_FirstName,
SR_LastName,
Brand,
VAT_Value_Percent,
Total_Price_EUR,
ContractType_NotTranslated,
ContractStatus,
ContractType,
StartDate,
Start_Day,
Start_Month,
Start_Year,
Today_D,
Today_M,
Today_Y,
OrderType,
RunTime,
CreatedById,
ContractCreatedDate,
Contract_Id,
Contract_Lead_Creator_Partner,
Contract_Salesrep_User,
Contract_AccountOwner,
InstallDate,
ProductName,
SerialNumber,
ProductUnitClass,
Country,
City,
PostalCode,
Street,
HouseNo,
FlatNo,
Floor_c

FROM(
SELECT
acc.Id as SubscriberKey,
acc.PersonContactId as Subscriberkey2,
acc.Salutation as Salutation,
acc.FirstName as FirstName,
acc.LastName as LastName,
acc.Name as AccountName,
acc.PersonEmail as Emailadress, 
acc.AccountNumber as AccountNumber,
acc.BillingCountryCode as BillingCountry,
acc.BillingCity as BillingCity,
acc.BillingPostalCode as BillingPostalCode,
acc.BillingStreet  as BillingStreet,
acc.BillingFlatNo__c as BillingFlatNo,
acc.BillingFloor__c as BillingFloor,
acc.TemplateLanguage__c as Language,

acc2.FirstName as SR_FirstName,
acc2.LastName as SR_LastName,

/*scc.DescriptionSpecialTerms__c as VAT_Value_Percent,
scc.DescriptionInternal__c as Total_Price_EUR,*/
scc.Name as ContractType_NotTranslated, 
scc.Status as ContractStatus,
scc.FSL_Tentative_Start_Date__c as StartDate,
datepart(day,scc.FSL_Tentative_Start_Date__c) as Start_Day,
datepart(month,scc.FSL_Tentative_Start_Date__c) as Start_Month, 
datepart(year,scc.FSL_Tentative_Start_Date__c) as Start_Year,
datepart(day,getdate()) as Today_D,
datepart(month,getdate()) as Today_M,
datepart(year,getdate()) as Today_Y,
scc.OrderType__c as OrderType,
scc.Term as RunTime,
scc.CreatedById as CreatedById,
scc.ConclusionDate__c as ContractCreatedDate,
scc.Id as Contract_Id,
/*scc.LeadCreatorPartner__c as Contract_Lead_Creator_Partner,*/
/*scc.ContractSeller__c as Contract_Salesrep_User,*/
scc.Invoice_Recipient__c as Contract_AccountOwner,

asset.InstallDate as InstallDate, 
asset.Name as ProductName,
asset.SerialNumber as SerialNumber
asset.ProductUnitClass__c as ProductUnitClass,
asset.Brand__c as Brand,

loc.Country__c as Country,
loc.City__c as City,
loc.PostalCode__c as PostalCode,
loc.Street__c as Street,
loc.HouseNo__c as HouseNo,
loc.FlatNo__c as FlatNo,
loc.Floor__c as Floor_c,

ROW_NUMBER ( ) OVER ( PARTITION BY scc.Id ORDER BY scc.Brand__c ASC ) AS RowNumber


FROM ENT.Account_Salesforce_2 acc
INNER JOIN ENT.ServiceContract_Salesforce_4 scc on scc.AccountId = acc.id
INNER JOIN ENT.ContractLineItem_Salesforce cli on cli.ServiceContractId = scc.id
INNER JOIN ENT.Asset_Salesforce_5 asset on asset.id = cli.AssetId
INNER JOIN ENT.Location_Salesforce loc on loc.id = asset.LocationId
INNER JOIN ENT.Account_Salesforce_2 acc2 on scc.Service_Recipient__c = acc2.Id

WHERE scc.Status = 'suspended' /*Status__c => Status, new values are "Inactive", "Active", "Expired"*/
and (scc.CreatedById = '005w0000004NnjNAAS' or scc.CreatedById = '005w0000006RcbOAAS')
and datepart(day,scc.Crea) = datepart(day,getdate())
and datepart(month,scc.ConclusionDate__c) = datepart(month,getdate())
and datepart(year,scc.ConclusionDate__c) = datepart(year,getdate())
/*and scc.LeadCreatorPartner__c is null
and scc.ContractSeller__c is null*/

)

AS Sub
WHERE RowNumber=1
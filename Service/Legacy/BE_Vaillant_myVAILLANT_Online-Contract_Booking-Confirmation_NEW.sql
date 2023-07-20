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
ContractDuration, /*tbv*/
ContractDuration_2, /*tbv*/
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
Installatiedatum,
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
acc.id as SubscriberKey,
acc.PersonContactId as Subscriberkey2,
acc.Salutation as Salutation,
acc.FirstName as FirstName,
acc.LastName as LastName,
acc.Name as AccountName,
acc.PersonEmail as Emailadress,
acc.AccountNumber as AccountNumber,
acc.BillingCountry__c as BillingCountry,
acc.BillingCity__c as BillingCity,
acc.BillingPostalCode__c as BillingPostalCode,
acc.BillingStreet__c  as BillingStreet,
acc.BillingHouseNo__c as BillingHouseNo,
acc.BillingFlatNo__c as BillingFlatNo,
acc.BillingFloor__c as BillingFloor,
acc.LocaleSidKey__c as PrefLanguage,

acc2.FirstName as SR_FirstName,
acc2.LastName as SR_LastName,

scc.Brand__c as Brand,
scc.DescriptionSpecialTerms__c as VAT_Value_Percent,
scc.DescriptionInternal__c as Total_Price_EUR,
scc.MaintenanceDuration__c as ContractDuration, /*tbv*/
scc.util_MaintenanceDuration__c as ContractDuration_2, /*tbv*/
scc.util_templatedetails__c as ContractType_NotTranslated,
scc.Status__c as ContractStatus,
    scc.StartDate__c as StartDate,
    datepart(day,scc.StartDate__c) as Start_Day,
    datepart(month,scc.StartDate__c) as Start_Month,
    datepart(year,scc.StartDate__c) as Start_Year,
    datepart(day,getdate()) as Today_D,
    datepart(month,getdate()) as Today_M,
    datepart(year,getdate()) as Today_Y,
scc.OrderType__c as OrderType,
scc.Runtime__c	as RunTime,
scc.CreatedById as CreatedById,
scc.ConclusionDate__c as ContractCreatedDate,
scc.Id as Contract_Id,
scc.LeadCreatorPartner__c as Contract_Lead_Creator_Partner,
scc.ContractSeller__c as Contract_Salesrep_User,
scc.AccountOwner__c as Contract_AccountOwner,

ib.InstallationDate__c	as Installatiedatum,
ib.ProductNameCalc__c as ProductName,
ib.SerialNo__c	as SerialNumber,
ib.ProductUnitClass__c as ProductUnitClass,

ibl.Country__c as Country,
ibl.City__c as City,
ibl.PostalCode__c as PostalCode,
ibl.Street__c as Street,
ibl.HouseNo__c as HouseNo,
ibl.FlatNo__c as FlatNo,
ibl.Floor__c as Floor_c,

CASE
when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c ='Omnium (BE) CSSP')
then replace(scc.util_templatedetails__c,'Omnium (BE) CSSP','Omnium')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Omnium (BE) CSSP')
then replace(scc.util_templatedetails__c,'Omnium (BE) CSSP','Omnium')

when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c = 'Omnium (BE) CSSP - Bruxelles')
then replace(scc.util_templatedetails__c,'Omnium (BE) CSSP - Bruxelles','Omnium')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Omnium (BE) CSSP - Bruxelles')
then replace(scc.util_templatedetails__c,'Omnium (BE) CSSP - Bruxelles','Omnium')

when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c = 'Standard (BE) CSSP')
then replace(scc.util_templatedetails__c,'Standard (BE) CSSP','Standard')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Standard (BE) CSSP')
then replace(scc.util_templatedetails__c,'Standard (BE) CSSP','Standaard')

when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c = 'Standard (BE) CSSP - Bruxelles')
then replace(scc.util_templatedetails__c,'Standard (BE) CSSP - Bruxelles','Standard')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Standard (BE) CSSP - Bruxelles')
then replace(scc.util_templatedetails__c,'Standard (BE) CSSP - Bruxelles','Standaard')

when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c = 'Standard 24 Month CSSP (BE)')
then replace(scc.util_templatedetails__c,'Standard 24 Month CSSP (BE)','Standard')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Standard 24 Month CSSP (BE)')
then replace(scc.util_templatedetails__c,'Standard 24 Month CSSP (BE)','Standaard')

when (acc.LocaleSidKey__c = 'fr' and scc.util_templatedetails__c = 'Standard 24 Month CSSP (BE) - Bruxelles')
then replace(scc.util_templatedetails__c,'Standard 24 Month CSSP (BE) - Bruxelles','Standard')

when (acc.LocaleSidKey__c = 'nl' and scc.util_templatedetails__c = 'Standard 24 Month CSSP (BE) - Bruxelles')
then replace(scc.util_templatedetails__c,'Standard 24 Month CSSP (BE) - Bruxelles','Standaard')

ELSE 'Standard'
END AS ContractType,
ROW_NUMBER ( ) OVER ( PARTITION BY scc.Id ORDER BY scc.Brand__c ASC ) AS RowNumber


FROM ENT.Account_Salesforce_2 acc
INNER JOIN ENT.SCContract__c_Salesforce_5 scc on scc.AccountOwner__c = acc.id
INNER JOIN ENT.SCContractItem__c_Salesforce_2 sci on sci.Contract__c = scc.id
INNER JOIN ENT.SCInstalledBase__c_Salesforce_5 ib on ib.id = sci.InstalledBase__c
INNER JOIN ENT.SCInstalledBaseLocation__c_Salesforce_3 ibl on ibl.id = ib.installedbaselocation__c
INNER JOIN ENT.Account_Salesforce_2 acc2 on scc.Account__c = acc2.Id

WHERE scc.Status__c = 'suspended'
and (scc.CreatedById = '005w0000004NnjNAAS' or scc.CreatedById = '005w0000006RcbOAAS')
and datepart(day,scc.ConclusionDate__c) = datepart(day,getdate())
and datepart(month,scc.ConclusionDate__c) = datepart(month,getdate())
and datepart(year,scc.ConclusionDate__c) = datepart(year,getdate())
/*and scc.LeadCreatorPartner__c is null
and scc.ContractSeller__c is null*/

)

AS Sub
WHERE RowNumber=1
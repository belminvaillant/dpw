SELECT
Account_Id,
Account_DeleteStatus,
Account_Name,
Individual_Id,
IsPersonAccount,
Person_Account_Id,
Account_Number,
LocaleSidKey__c,
Account_Mobile,
Account_Phone,
Account_Email,
Name2,
Name3,
Billing_Street,
Billing_HouseNo,
Billing_Floor,
Billing_FlatNo,
Billing_PostalCode,
Billing_City,
Billing_Country,
Contract_AccountId__c,
ContractDetailTemplate,
Contract_Status,
FrameContract,
ContractBrand,
ContractStartDate__c,
DepartmentBU,
ContractVisit_Status__c,
ContractVisitId__c,
ContractVisit_Contract__c,
Contract_VisitDueDate,
ContractVisit_OriginalDueDate,
ContractItemContract__c,
ProductModel__c,
CV_InstalledBase_Id,
InstalledBase_Id,
ProductUnitClass

FROM(

SELECT
acc.Id as Account_Id,
acc.DeleteStatus__c as Account_DeleteStatus,
acc.Name as Account_Name,
acc.PersonIndividualId as Individual_Id,
acc.IsPersonAccount as IsPersonAccount,
acc.PersonContactId as Person_Account_Id,
acc.AccountNumber as Account_Number,
acc.TemplateLanguage__c as Recipient_Language, /*LocaleSidKey__c => TemplateLanguage__c*/
acc.Mobile__c as Account_Mobile,
acc.Phone as Account_Phone,
acc.Email__c as Account_Email,
acc.Name2__c as Name2,
acc.Name3__c as Name3,
acc.BillingStreet__c as Billing_Street,
acc.BillingHouseNo__c as Billing_HouseNo,
acc.BillingFloor__c as Billing_Floor,
acc.BillingFlatNo__c as Billing_FlatNo,
acc.BillingPostalCode__c as Billing_PostalCode,
acc.BillingCity__c as Billing_City,
acc.BillingCountry__c as Billing_Country,
co.Account__c as Contract_AccountId__c,
co.util_templatedetails__c as ContractDetailTemplate,
co.Status__c as Contract_Status,
co.Frame__c as FrameContract,
co.Brand__c as ContractBrand,
co.StartDate__c as ContractStartDate__c,
co.DepartmentCurrent__c as DepartmentBU,
cov.Status__c as ContractVisit_Status__c,
cov.Id as ContractVisitId__c,
cov.Contract__c as ContractVisit_Contract__c,
cov.DueDate__c as Contract_VisitDueDate,
cov.OriginalDueDate__c as ContractVisit_OriginalDueDate,
coi.Contract__c as ContractItemContract__c,
coi.util_ib_product_model__c as ProductModel__c,
coi.InstalledBase__c as CV_InstalledBase_Id,
ins.Id as InstalledBase_Id,
ins.ProductUnitClass__c as ProductUnitClass,
ROW_NUMBER ( ) OVER ( PARTITION BY acc.PersonContactId ORDER BY acc.Name ASC ) AS RowNumber

FROM ENT.Account_Salesforce_2 acc

INNER JOIN ENT.SCContract__c_Salesforce_5 co on acc.Id = co.Account__c
INNER JOIN ENT.SCContractItem__c_Salesforce_2 coi on coi.Contract__c = co.Id
INNER JOIN ENT.SCContractVisit__c_Salesforce_1 cov on cov.Contract__c = co.Id    
INNER JOIN ENT.SCInstalledBase__c_Salesforce_5 ins on ins.Id = coi.InstalledBase__c

WHERE
acc.DeleteStatus__c IS NULL
AND acc.BillingCountry__c = 'BE'
AND acc.PersonContactId <> '' 
AND co.Status = 'Active'
AND acc.Email__c <> ''
AND co.Frame__c IS NULL 
AND co.EndDate / FSL_RenewalDate__c
AND co.TemplateId__c (Frame and Bulk)
AND co.FSL_Type_of_Contract__c 

/*AND cov.DueDate__c > '05/01/2020'*/
/*AND cov.Status__c = 'schedule'*/
/*AND co.Brand__c = 'a0B2000000A7ew8EAB'*/
/*AND co.util_templatedetails__c NOT LIKE '%Extended Warranty%'*/
/*AND (ins.ProductUnitClass__c != '08' AND ins.ProductUnitClass__c != '07' AND ins.ProductUnitClass__c != '03' AND ins.ProductUnitClass__c != '10')
/*AND (coi.util_ib_product_model__c NOT LIKE '%Other%' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [145]' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [115]' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [175]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [806]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [1206]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [1006]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [1206]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [1606]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2006]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2406]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2806]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [806]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [186]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [246]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [306]' AND coi.util_ib_product_model__c != 'VUW ecoTEC /5-7 exclusive [356]' AND coi.util_ib_product_model__c != 'VUW ecoTEC /5-7 exclusive [436]' AND coi.util_ib_product_model__c != 'VC ecoTEC /8-5 plus (loni) [206]')*/
/*AND NOT EXISTS (Select 1 FROM BE_Vaillant_CSSP_Maintenance_Pilot be WHERE be.Person_Account_Id = acc.PersonContactId)
)
AS Sub
WHERE RowNumber=1

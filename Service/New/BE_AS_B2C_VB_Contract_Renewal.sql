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
ir.Id as Account_Id,  /*OK*/
sr.Id as Service_Recipient, /*OK*/
ir.Id as Invoice_Recipient,  /*OK*/
ir.IsDeleted as Account_DeleteStatus,  /*DeleteStatus__c => IsDeleted*/
ir.Name as Account_Name, /*OK*/
ir.PersonIndividualId as Individual_Id, /*OK*/
ir.IsPersonAccount as IsPersonAccount, /*OK*/
ir.PersonContactId as Person_Account_Id, /*OK*/
ir.AccountNumber as Account_Number, /*OK*/
ir.TemplateLanguage__c as Recipient_Language, /*LocaleSidKey__c => TemplateLanguage__c*/
ir.Email__c as Account_Email,  /*OK*/
ir.PersonMobilePhone as Account_Phone,
sr.BillingStreet__c as Billing_Street,
sr.BillingHouseNo__c as Billing_HouseNo,
sr.BillingFloor__c as Billing_Floor,
sr.BillingFlatNo__c as Billing_FlatNo,
sr.BillingPostalCode__c as Billing_PostalCode,
sr.BillingCity__c as Billing_City,
sr.BillingCountry__c as Billing_Country,
  
co.Account__c as Contract_AccountId__c,
co.util_templatedetails__c as ContractDetailTemplate,
co.Status__c as Contract_Status,
co.Frame__c as FrameContract,
co.Brand__c as ContractBrand,
co.StartDate__c as ContractStartDate__c,
co.DepartmentCurrent__c as DepartmentBU,

pb.Brand__c as Brand,
  
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

FROM ENT.ServiceContract_Salesforce_4 co

INNER JOIN ENT.Account_Salesforce_21 sr on acc.Id = co.Service_Recipient__c
INNER JOIN ENT.Account_Salesforce_21 ir on acc.Id = co.Invoice_Recipient__c
INNER JOIN ENT.Pricebook2_Salesforce pb on pb.Id = co.Pricebook2Id

WHERE
ir.DeleteStatus__c IS NULL  /*OK*/
AND ir.PersonContactId <> '' /*OK*/
AND ir.Email__c <> '' /*OK*/

AND co.TemplateCountry__c = 'BE' /*OK*/
AND co.Status = 'Active' /*OK*/
AND co.FSL_Cancellation_Status__c	= '' /*OK*/
AND co.EndDate = DateAdd(NOW(),m,2) /*of is het FSL_Tentative_End_Date__c?*/
AND co.TemplateId__c (Frame and Bulk)
AND co.FSL_Type_of_Contract__c /* Needed? */  

  
/*AND co.util_templatedetails__c NOT LIKE '%Extended Warranty%'*/
/*AND (ins.ProductUnitClass__c != '08' AND ins.ProductUnitClass__c != '07' AND ins.ProductUnitClass__c != '03' AND ins.ProductUnitClass__c != '10')
/*AND (coi.util_ib_product_model__c NOT LIKE '%Other%' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [145]' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [115]' AND coi.util_ib_product_model__c != 'turboMAG /1 plus [175]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [806]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [1206]' AND coi.util_ib_product_model__c != 'VC ecoTEC /5-5 plus (80-120kW) [1006]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [1206]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [1606]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2006]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2406]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [2806]' AND coi.util_ib_product_model__c != 'VKK ecoCRAFT /3 [806]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [186]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [246]' AND coi.util_ib_product_model__c != 'VU ecoTEC /5-7 exclusive [306]' AND coi.util_ib_product_model__c != 'VUW ecoTEC /5-7 exclusive [356]' AND coi.util_ib_product_model__c != 'VUW ecoTEC /5-7 exclusive [436]' AND coi.util_ib_product_model__c != 'VC ecoTEC /8-5 plus (loni) [206]')*/
/*AND NOT EXISTS (Select 1 FROM BE_Vaillant_CSSP_Maintenance_Pilot be WHERE be.Person_Account_Id = acc.PersonContactId)
)
AS Sub
WHERE RowNumber=1

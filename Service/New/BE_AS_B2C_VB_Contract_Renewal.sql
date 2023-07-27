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
  
co.EndDate as Contract_EndDate, /*OK*/
co.Name as Contract_Name, /*OK*/
co.ContractNumber as Contract_Number, /*OK*/
co.TemplateId__c as Contract_Template_Name, /*OK*/
co.Status as Contract_Status, /*OK*/
co.Term as Contract_Term_Months, /*OK*/
  
pb.Brand__c as Brand, /*OK*/

prod.Name as Product_Name /*Which product name to put in the email?*/
  
ROW_NUMBER ( ) OVER ( PARTITION BY acc.PersonContactId ORDER BY acc.Name ASC ) AS RowNumber

FROM ENT.ServiceContract_Salesforce_4 co

INNER JOIN ENT.Account_Salesforce_21 sr on acc.Id = co.Service_Recipient__c
INNER JOIN ENT.Account_Salesforce_21 ir on acc.Id = co.Invoice_Recipient__c
INNER JOIN ENT.Pricebook2_Salesforce pb on pb.Id = co.Pricebook2Id
INNER JOIN ENT.MaintenancePlan_Salesforce mp on co.Id = mp.ServiceContractId
INNER JOIN ENT.MaintenanceAsset_Salesforce mass on mass.MaintenancePlanId = mp.Id
INNER JOIN ENT.Asset_Salesforce_5 ass on mp.AssetId = ass.Id
INNER JOIN ENT.Product2 prod on prod.id = ass.Product2Id
/*INNER JOIN ENT.WorkOrder_Salesforce wo on wo. Needed? */

WHERE
ir.DeleteStatus__c IS NULL  /*OK*/
AND ir.PersonContactId <> '' /*OK*/
AND ir.Email__c <> '' /*OK*/

AND co.TemplateCountry__c = 'BE' /*OK*/
AND co.Status = 'Active' /*OK*/
AND co.FSL_Cancellation_Status__c	= '' /*OK*/
AND co.EndDate = DateAdd(NOW(),m,2)
AND co.TemplateId__c (Frame and Bulk)
AND co.FSL_Type_of_Contract__c /* Needed? */  
/* Do we need to exclude certain types of products?*/
  
)
AS Sub
WHERE RowNumber=1

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
ir.Id as Account_Id, 
sr.Id as Service_Recipient, 
ir.Id as Invoice_Recipient,  
ir.IsDeleted as Account_DeleteStatus,  
ir.Name as Account_Name, 
ir.PersonIndividualId as Individual_Id, 
ir.IsPersonAccount as IsPersonAccount, 
ir.PersonContactId as Person_Account_Id, 
ir.AccountNumber as Account_Number, 
ir.TemplateLanguage__c as Recipient_Language, 
ir.Email__c as Account_Email,  
ir.PersonMobilePhone as Account_Phone,
sr.BillingStreet__c as Billing_Street,
sr.BillingHouseNo__c as Billing_HouseNo,
sr.BillingFloor__c as Billing_Floor,
sr.BillingFlatNo__c as Billing_FlatNo,
sr.BillingPostalCode__c as Billing_PostalCode,
sr.BillingCity__c as Billing_City,
sr.BillingCountry__c as Billing_Country,
  
co.EndDate as Contract_EndDate,
co.Name as Contract_Name,
co.ContractNumber as Contract_Number, 
co.TemplateId__c as Contract_Template_Name, 
co.Status as Contract_Status, 
co.Term as Contract_Term_Months,
co.FSL_Type_of_Contract__c as Contract_Type,

pb.Brand__c as Brand, 

prod.Name as Product_Name 
FROM ENT.ServiceContract_Salesforce_4 co

INNER JOIN ENT.Account_Salesforce_21 sr on sr.Id = co.Service_Recipient__c
INNER JOIN ENT.Account_Salesforce_21 ir on ir.Id = co.Invoice_Recipient__c
INNER JOIN ENT.Pricebook2_Salesforce pb on pb.Id = co.Pricebook2Id
INNER JOIN ENT.MaintenancePlan_Salesforce mp on co.Id = mp.ServiceContractId
INNER JOIN ENT.MaintenanceAsset_Salesforce mass on mass.MaintenancePlanId = mp.Id
INNER JOIN ENT.Asset_Salesforce_5 ass on mass.AssetId = ass.Id
INNER JOIN ENT.Product2_Salesforce prod on prod.id = ass.Product2Id

WHERE
ir.IsDeleted = 'false' 
AND ir.PersonContactId <> '' 
AND ir.Email__c <> ''

AND co.TemplateCountry__c = 'BE' 
AND co.Status = 'Active' 
AND co.FSL_Cancellation_Status__c = '' 
AND co.EndDate <= DateAdd(month, 2, getdate())

AND co.TemplateId__c (Frame and Bulk)
AND co.FSL_Type_of_Contract__c /* Needed? */  
/* Do we need to exclude certain types of products?*/
  
)
AS Sub
WHERE RowNumber=1

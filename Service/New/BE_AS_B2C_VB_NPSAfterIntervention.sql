SELECT
Account_Id,
Account_FirstName,
Account_LastName,
Account_Name,
Account_Salutation,
Account_Email,
Account_Mobile,
Account_PersonContactId,
Appointment_Start,
Appointment_Date,
Appointment_Id,
Appointment_AssignmentStatus,
Appointment_Employee,
Order_Name,
Order_Id,
Order_CSSToken,
Order_Type,
Order_Reason,
Order_Brand,
Order_Status,
Order_TimeWindow,
Order_FailureType,
Order_ExternalId,
Order_Country,
Order_InvoicingSubtype,
Order_DepartmentCurrent,
OrderRole_Language,
OrderRole_OrderRole,
Contract_Name,
Contract_Status, 
Contract_ExternalId,
Contract_TemplateDetails

FROM(
SELECT
acc.Id as Account_Id,
acc.FirstName as Account_FirstName,
acc.LastName as Account_LastName,  
acc.Name as Account_Name,
acc.Salutation as Account_Salutation,
acc.Email__c as Account_Email,
acc.Mobile__c as Account_Mobile,
acc.PersonContactId as Account_PersonContactId,
app.Start__c as Appointment_Start,
Convert(varchar(10), app.Start__c, 103) as Appointment_Date,
app.Id as Appointment_Id,
app.AssignmentStatus__c as Appointment_AssignmentStatus,
app.Employee__c as Appointment_Employee,
ord.Name as Order_Name,
ord.Id as Order_Id,
ord.CSSOrderToken__c as Order_CSSToken,
ord.Type__c as Order_Type,
ord.OrderReason__c as Order_Reason,
ord.Brand__c as Order_Brand,
ord.Status__c as Order_Status,
ord.CustomerTimewindow__c as Order_TimeWindow,
ord.FailureType__c as Order_FailureType,
ord.IdExt__c as Order_ExternalId,
ord.Country__c as Order_Country,
ord.DepartmentCurrent__c as Order_DepartmentCurrent,
ord.InvoicingSubtype__c as Order_InvoicingSubtype,
orr.LocaleSidKey__c as OrderRole_Language,
orr.OrderRole__c as OrderRole_OrderRole,
co.Name as Contract_Name,
co.Status__c as Contract_Status, 
co.IdExt__c as Contract_ExternalId,
co.util_templatedetails__c as Contract_TemplateDetails,
ROW_NUMBER ( ) OVER ( PARTITION BY acc.Email__c ORDER BY app.Start__c DESC ) AS RowNumber

FROM
ENT.Account_Salesforce_2 acc
LEFT JOIN ENT.SCContract__c_Salesforce_5 co ON acc.Id = co.Account__c AND co.Status__c = 'Active'
INNER JOIN ENT.SCOrderRole__c_Salesforce_2 orr ON acc.id = orr.Account__c
INNER JOIN ENT.SCOrder__c_Salesforce_2 ord ON orr.Order__c = ord.Id
INNER JOIN ENT.SCAppointment__c_Salesforce_2 app ON app.Order__c = ord.Id
 
WHERE
acc.Email__c IS NOT NULL
AND acc.Email__c NOT IN ('sparidaens@logiris.brussels', 'toitetmoi@bulex.com', 'dimitri.props@volkshaard.be' ,'technischedienst@wm-impuls.be', 'onderhoud@cvketelshuren.com', 'fmarchant@abcoop.be', 'brichaud.ratkovic@gmail.com','sabine.rombauts@hkh.vlaanderen')
AND ord.Country__c = 'BE'
AND acc.PersonContactId <> ''
AND acc.DeleteStatus__c IS NULL
AND convert(int,dateadd(day,convert(float,getdate()),-1))=convert(int,app.Start__c)
AND orr.OrderRole__c = '50301'
AND app.AssignmentStatus__c IN ('5506','5508')
AND ord.Status__c IN ('5506','5508')
AND ord.FailureType__c NOT IN ('3619','3624')
AND YEAR(app.Start__c) = '2023'

)
AS Sub
WHERE RowNumber=1
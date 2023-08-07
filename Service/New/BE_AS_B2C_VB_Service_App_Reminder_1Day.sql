SELECT
Appointment_Id,
Appointment_Country,
Appointment_StartDay, 
Appointment_StartTime,
Appointment_EndTime,
CASE
    WHEN (SR_Language = 'NL' AND (Appointment_StartTime >= '00:00' AND Appointment_StartTime <= '10:59')) THEN '07u30 en 12u'
    WHEN (SR_Language = 'NL' AND (Appointment_StartTime >= '11:00' AND Appointment_StartTime <= '12:59')) THEN '10u en 14u'
    WHEN (SR_Language = 'NL' AND (Appointment_StartTime >= '13:00' AND Appointment_StartTime <= '23:59')) THEN '13u en 18u'
    WHEN (SR_Language = 'FR' AND (Appointment_StartTime >= '00:00' AND Appointment_StartTime <= '10:59')) THEN '07h30 et 12h'
    WHEN (SR_Language = 'FR' AND (Appointment_StartTime >= '11:00' AND Appointment_StartTime <= '12:59')) THEN '10h et 14h'
    WHEN (SR_Language = 'FR' AND (Appointment_StartTime >= '13:00' AND Appointment_StartTime <= '23:59')) THEN '13h et 18h'
    ELSE Appointment_StartTime
END as CommunicatedTimeWindow,
Appointment_Status, 
Appointment_Street,
Appointment_City,
Appointment_PostalCode,
Appointment_Type,
Appointment_WorkTypeId,
Appointment_Number,

Order_Id,
Order_SR,
Order_IR,
Order_ContractId,
Order_Status,

Contract_Id,

SR_Id,
SR_PersonAccount,
SR_FirstName,
SR_LastName,
SR_Email, 
SR_AccountNumber,
SR_Language,
SR_MobilePhone,

Asset_Brand,

RowNumber

FROM 
(SELECT TOP 5000

app.Id as Appointment_Id,
app.Country as Appointment_Country,
convert(varchar, app.FSL_Scheduled_Start__c, 103) as Appointment_StartDay, 
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.FSL_Scheduled_Start__c))) as Appointment_StartTime,
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.FSL_Scheduled_End__c))) as Appointment_EndTime,
app.Status as Appointment_Status, 
app.Street as Appointment_Street,
app.City as Appointment_City,
app.PostalCode as Appointment_PostalCode,
app.FSL_Type__c as Appointment_Type,
app.WorkTypeId as Appointment_WorkTypeId,
app.AppointmentNumber as Appointment_Number,

ord.Id as Order_Id,
ord.AccountId as Order_SR,
ord.FSL_Invoice_Recipient__c as Order_IR,
ord.ServiceContractId as Order_ContractId,
ord.Status as Order_Status,

con.Id as Contract_Id,
con.FrameReferenceNumber__c as Contract_Frame,

sr.Id as SR_Id,
sr.IsPersonAccount as SR_PersonAccount,
sr.FirstName as SR_FirstName,
sr.LastName as SR_LastName,
sr.PersonEmail as SR_Email, 
sr.AccountNumber as SR_AccountNumber,
sr.TemplateLanguage__c as SR_Language,
sr.PersonMobilePhone as SR_MobilePhone,

asset.Brand__c as Asset_Brand,

ROW_NUMBER () OVER (PARTITION BY sr.Id ORDER BY app.FSL_Scheduled_Start__c ASC ) AS RowNumber

FROM ENT.WorkOrder_Salesforce ord
INNER JOIN ENT.ServiceAppointment_Salesforce app on ord.Id = app.FSL_Work_Order__c
LEFT JOIN ENT.ServiceContract_Salesforce_4 con on ord.ServiceContractId = con.Id
LEFT JOIN ENT.Account_Salesforce_21 sr on ord.AccountId = sr.Id
LEFT JOIN ENT.Account_Salesforce_21 ir on ord.FSL_Invoice_Recipient__c = ir.Id
LEFT JOIN ENT.Asset_Salesforce_5 asset on asset.Id = ord.AssetId 

WHERE
convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.FSL_Scheduled_Start__c)
AND app.Country = 'Belgium'
AND ord.Status = 'In Progress'
AND sr.TemplateLanguage__c IN ('FR', 'NL') /*Only for testing purposes*/
AND app.Status != 'Cancelled'

ORDER BY app.ActualStartTime ASC

)
AS Sub
WHERE RowNumber = 1
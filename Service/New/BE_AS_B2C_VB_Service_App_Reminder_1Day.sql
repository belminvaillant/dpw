SELECT
Appointment_Id,
Appointment_Country,
Appointment_StartDay, 
Appointment_StartTime,
Appointment_EndTime,
CASE
    WHEN (Recipient_Language = 'NL' AND (Appointment_StartTime >= '00:00' AND Appointment_StartTime <= '10:59')) THEN '07u30 en 12u'
    WHEN (Recipient_Language = 'NL' AND (Appointment_StartTime >= '11:00' AND Appointment_StartTime <= '12:59')) THEN '10u en 14u'
    WHEN (Recipient_Language = 'NL' AND (Appointment_StartTime >= '13:00' AND Appointment_StartTime <= '23:59')) THEN '13u en 18u'
    WHEN (Recipient_Language = 'FR' AND (Appointment_StartTime >= '00:00' AND Appointment_StartTime <= '10:59')) THEN '07h30 et 12h'
    WHEN (Recipient_Language = 'FR' AND (Appointment_StartTime >= '11:00' AND Appointment_StartTime <= '12:59')) THEN '10h et 14h'
    WHEN (Recipient_Language = 'FR' AND (Appointment_StartTime >= '13:00' AND Appointment_StartTime <= '23:59')) THEN '13h et 18h'
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
Order_AccountId,
Order_ContractId,
Order_Status,

Contract_Id,

Recipient_Id,
Recipient_PersonAccount,
Recipient_FirstName,
Recipient_LastName,
Recipient_Email, 
Recipient_AccountNumber,
Recipient_Language,
Recipient_MobilePhone,

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
ord.AccountId as Order_AccountId,
ord.ServiceContractId as Order_ContractId,
ord.Status as Order_Status,

con.Id as Contract_Id,
con.FrameReferenceNumber__c as Contract_Frame,
/*

CASE 
    WHEN (con.Frame__c IN ('a0C1r00003pBl9xEAC', 'a0C1r00003pBn8fEAC', 'a0C1r00003pBnc1EAC', 'a0C1r00003pAp8fEAC', 'a0C1r000042mBBuEAM', 'a0C6900004FDg8cEAD', 'a0C1r000043BCxWEAW', 'a0C1r00004AWdHDEA1', 'a0C69000048JyyFEAS', 'a0C6900004NgIJoEAN', 'a0C1r00003w47NVEAY', 'a0Cw000001GNm6qEAD', 'a0C6900004O0WqtEAF', 'a0C6900004DiveKEAR', 'a0C1r00003xRltxEAC')) THEN 'No'
    ELSE 'Yes'
END AS InScope,*/

acc.Id as Recipient_Id,
acc.IsPersonAccount as Recipient_PersonAccount,
acc.FirstName as Recipient_FirstName,
acc.LastName as Recipient_LastName,
acc.PersonEmail as Recipient_Email, 
acc.AccountNumber as Recipient_AccountNumber,
acc.TemplateLanguage__c as Recipient_Language,
acc.PersonMobilePhone as Recipient_MobilePhone,

asset.Brand__c as Asset_Brand,

ROW_NUMBER () OVER (PARTITION BY acc.Id ORDER BY app.FSL_Scheduled_Start__c ASC ) AS RowNumber

FROM ENT.WorkOrder_Salesforce ord
INNER JOIN ENT.ServiceAppointment_Salesforce app on ord.Id = app.FSL_Work_Order__c
LEFT JOIN ENT.ServiceContract_Salesforce_4 con on ord.ServiceContractId = con.Id
LEFT JOIN ENT.Account_Salesforce_21 acc on ord.AccountId = acc.Id
LEFT JOIN ENT.Asset_Salesforce_5 asset on asset.Id = ord.AssetId 

WHERE
convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.FSL_Scheduled_Start__c)
AND app.Country = 'Belgium'
AND ord.Status = 'In Progress'
AND acc.TemplateLanguage__c IN ('FR', 'NL')
AND app.Status != 'Cancelled'

ORDER BY app.ActualStartTime ASC

)
AS Sub
WHERE RowNumber = 1
SELECT
AmountOfAppointments,
Appointment_Id,
Appointment_Order__c,
Appointment_TimeWindow__c,
StartDay,
StartTime,
CASE
    WHEN (OrderRole_LocaleSidKey__c = 'nl' AND (StartTime >= '00:00' AND StartTime <= '10:59')) THEN '07u30 en 12u'
    WHEN (OrderRole_LocaleSidKey__c = 'nl' AND (StartTime >= '11:00' AND StartTime <= '12:59')) THEN '10u en 14u'
    WHEN (OrderRole_LocaleSidKey__c = 'nl' AND (StartTime >= '13:00' AND StartTime <= '23:59')) THEN '13u en 18u'
    WHEN (OrderRole_LocaleSidKey__c = 'fr' AND (StartTime >= '00:00' AND StartTime <= '10:59')) THEN '07h30 et 12h'
    WHEN (OrderRole_LocaleSidKey__c = 'fr' AND (StartTime >= '11:00' AND StartTime <= '12:59')) THEN '10h et 14h'
    WHEN (OrderRole_LocaleSidKey__c = 'fr' AND (StartTime >= '13:00' AND StartTime <= '23:59')) THEN '13h et 18h'
    ELSE StartTime
END as CommunicatedTimeWindow,
EndTime,
Appointment_AssignmentStatus__c,
Order_Closed__c,
Order_Description__c,
Order_CustomerTimeWindow__c,
Order_InvoicingSubType__c,
Order_Status__c,
Asset_BrandName,
Contract_IdExt__c,
Contract_Frame__c,
InScope,
OrderRole_Account__c,
OrderRole_LocaleSidKey__c,
Recipient_Id,
Recipient_Email,
Recipient_AccountNumber,
Recipient_Language,
OrderRole_Name1__c,
OrderRole_MobilePhone__c,
OrderRole_Street__c,
OrderRole_HouseNo__c,
OrderRole_Floor__c,
OrderRole_FlatNo__c,
OrderRole_PostalCode__c,
OrderRole_City__c,

Assignment_Name

FROM 
(SELECT TOP 5000
app.Id as Appointment_Id,
app.ParentRecordId as Appointment_Order__c, /*Order__c => ParentRecordId*/
app.Country as Appointment_Country__c, /*Country__c => Country*/
convert(varchar, app.ActualEndTime, 103) as StartDay, /*End__c = > ActualEndTime*/
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.ActualStartTime))) as StartTime, /*Start__c => ActualStartTime*/
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.ActualEndTime))) as EndTime, /*End__c = > ActualEndTime*/
app.ActualStartTime as Appointment_Start__c, /*Start__c => ActualStartTime*/
app.TimeWindow__c as Appointment_TimeWindow__c, /*If no direct field => Take ActualStart Time and ActualEndTime*/
app.Status as Appointment_AssignmentStatus__c, /*AssignmentStatus__c => Status*/

ord.Id as Order_Order__c, /*OK*/
ord.ServiceContractId as Order_Contract__c,/*Contract__c => ServiceContractId*/
ord.Description as Order_Description__c, /*Description__c => Description*/
ord.CustomerTimeWindow__c as Order_CustomerTimeWindow__c, /*?*/
ord.Status as Order_Status__c, /*Status__c => Status*/
asset.Brand__c as Asset_BrandName, /*Order: Brand__c => Asset: Brand__c, values: Bulex => 0E, Vaillant => 0A, Saunier Duval => 0B*/

con.Id as Contract_Id,
con.IdExt__c as Contract_IdExt__c, /*?*/
con.Frame__c as Contract_Frame__c, /*?*/

CASE 
    WHEN (con.Frame__c IN ('a0C1r00003pBl9xEAC', 'a0C1r00003pBn8fEAC', 'a0C1r00003pBnc1EAC', 'a0C1r00003pAp8fEAC', 'a0C1r000042mBBuEAM', 'a0C6900004FDg8cEAD', 'a0C1r000043BCxWEAW', 'a0C1r00004AWdHDEA1', 'a0C69000048JyyFEAS', 'a0C6900004NgIJoEAN', 'a0C1r00003w47NVEAY', 'a0Cw000001GNm6qEAD', 'a0C6900004O0WqtEAF', 'a0C6900004DiveKEAR', 'a0C1r00003xRltxEAC')) THEN 'False'  /*?*/
    WHEN (con.Name IS NULL) THEN 'False' /*?*/
    ELSE 'True'
END AS InScope,

acc.Id as Recipient_Id, /*OK*/
acc.Email__c as Recipient_Email, /*OK*/
acc.AccountNumber as Recipient_AccountNumber, /*OK*/
acc.TemplateLanguage__c as Recipient_Language, /*LocaleSidKey__c => TemplateLanguage__c*/
/*rol.OrderRole__c as OrderRole_OrderRole__c, /*Maybe free to delete*/*/
acc.Name as Account_Name, /*OrderRole: Name => Account: Name, take name from Account*/
case 
	when left(rol.MobilePhone__c,2) = '00' /*Take from Account*/
		then
		replace(substring(rol.MobilePhone__c,3,len(rol.MobilePhone__c) - 2),' ','') /*Take from Account*/
	when left(rol.MobilePhone__c,1) = '0' /*Take from Account*/
		then
		replace(substring(rol.MobilePhone__c,2,len(rol.MobilePhone__c) - 1),' ','')/*Take from Account*/
	when left(rol.MobilePhone__c,1) = '+' /*Take from Account*/
		then
		replace(substring(rol.MobilePhone__c,2,len(rol.MobilePhone__c) - 1),' ','') /*Take from Account*/
	else
		rol.MobilePhone__c /*Take from Account*/
end as OrderRole_MobilePhone__c, /*Take from Account*/
rol.Street__c as OrderRole_Street__c, /*Take address from Asset Location or Service Appointment?*/
rol.HouseNo__c as OrderRole_HouseNo__c, /*Take address from Asset Location or Service Appointment?*/
rol.Floor__c as OrderRole_Floor__c, /*Take address from Asset Location or Service Appointment?*/
rol.FlatNo__c as OrderRole_FlatNo__c, /*Take address from Asset Location or Service Appointment?*/
rol.PostalCode__c as OrderRole_PostalCode__c, /*Take address from Asset Location or Service Appointment?*/
rol.City__c as OrderRole_City__c, /*Take address from Asset Location or Service Appointment?*/

ass.Name as Assignment_Name, /*?*/
ROW_NUMBER ( ) OVER ( PARTITION BY app.Id ORDER BY app.ActualStartTime ASC ) AS RowNumber, /*Start__c => ActualStartTime*/
Dense_Rank() OVER (PARTITION BY acc.Id, loc.Street /*Take Street from Location*/, rol.MobilePhone__c /*Take mobile from Account*/, acc.Email__c ORDER BY app.ActualStartTime /*Start__c => ActualStartTime*/ASC) AS AmountOfAppointments


FROM ENT.WorkOrder ord /*SCOrder__c to Work Order*/

INNER JOIN ENT.ServiceAppointment app on ord.Id = app.ParentRecordId /*Order__c => ParentRecordId*/
LEFT JOIN ENT.ServiceContract con on ord.ServiceContractId = con.Id /*Contract__c => ServiceContractId*/
LEFT JOIN ENT.Account acc on ord.AccountId = acc.Id /*We take recipient info from Account object instead of OrderRole object, Account__c => Work Order: AccountId*/
LEFT JOIN ENT.SCAssignment__c_Salesforce_2 ass on ord.Id = ass.Order__c
LEFT JOIN ENT.Asset asset on asset.Id = ord.AssetId /*SCInstalledBase__c => Asset, we take brand on Asset*/
LEFT JOIN ENT.Location loc on ass.LocationId = loc.Id /*Linking the Location object to Asset, will get address info etc from Location instead of OrderRole object */

WHERE

convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.ActualStartTime) /*Start__c => ActualStartTime*/
AND app.Country = 'BE' /*Country__c => Country*/
AND res.Name NOT LIKE 'Dummy%'
AND ord.Status = 'In Progress' /*Status__c => Status, old values ('5502', '5503', '5509', '5510') all become 'In Progress' value, check Excel mapping field*/
AND app.Status != '5507' /*AssignmentStatus__c => Status, check values see Excel*/

ORDER BY app.ActualStartTime ASC /*Start__c => ActualStartTime*/

)
AS Sub
WHERE RowNumber = 1
AND AmountOfAppointments = 1
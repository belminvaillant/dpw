SELECT
Appointment_Id,
Appointment_Order__c,
Appointment_TimeWindow__c,
StartDay,
CASE
    WHEN (Account_LocaleSidKey__c = 'nl' AND (StartTime >= '00:00' AND StartTime <= '10:59')) THEN '07u30 - 12u'
    WHEN (Account_LocaleSidKey__c = 'nl' AND (StartTime >= '11:00' AND StartTime <= '12:59')) THEN '10u - 14u'
    WHEN (Account_LocaleSidKey__c = 'nl' AND (StartTime >= '13:00' AND StartTime <= '23:59')) THEN '13u - 18u'
    WHEN (Account_LocaleSidKey__c = 'fr' AND (StartTime >= '00:00' AND StartTime <= '10:59')) THEN '07h30 - 12h'
    WHEN (Account_LocaleSidKey__c = 'fr' AND (StartTime >= '11:00' AND StartTime <= '12:59')) THEN '10h - 14h'
    WHEN (Account_LocaleSidKey__c = 'fr' AND (StartTime >= '13:00' AND StartTime <= '23:59')) THEN '13h - 18h'
    ELSE StartTime
END as TimeSlot,
StartTime,
EndTime,
Appointment_AssignmentStatus__c,

Order_Type__c,
Order_Closed__c,
Order_Description__c,
Order_CustomerTimeWindow__c,
TimeWindow,
Order_InvoicingSubType__c,
Order_Status__c,

Contract_Name,
Contract_Util_templatedetails__c,

OrderItem_ProductNameCalc__c,

Recipient_Id,
Recipient_Email,
Recipient_AccountNumber,
Recipient_Name,
Recipient_Phone,
Recipient_MobilePhone__c,

Location_Address,
Location_Floor,
Location_FlatNo,
Location_PostalCode,
Location_City,

Resource_Id,
Resource_Name,
Resource_FirstName__c,
Resource_LastName__c,
Resource_EMail__c,

Assignment_Name,

SubscriberKey,
Account_LocaleSidKey__c


FROM 
(SELECT TOP 5000
app.Id as Appointment_Id,
app.Order__c as Appointment_Order__c,
app.Country__c as Appointment_Country__c,
app.Resource__c as Appointment_Resource__c,
convert(varchar, app.End__c, 103) as StartDay,
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.ActualStartTime))) as StartTime, /*Start__c => ActualStartTime*/
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.ActualEndTime))) as EndTime, /*End__c = > ActualEndTime*/
app.ActualStartTime as Appointment_Start__c, /*Start__c => ActualStartTime*/
app.TimeWindow__c as Appointment_TimeWindow__c, /*If no direct field => Take ActualStart Time and ActualEndTime*/
app.Status as Appointment_AssignmentStatus__c, /*AssignmentStatus__c => Status*/

ord.Id as Order_Order__c,
ord.ServiceContractId as Order_Contract__c, /*Contract__c => ServiceContractId*/
ord.Closed__c as Order_Closed__c, /*Closed__c => FSL_Service_Intervention_Date__c*/
ord.InvoicingSubType__c as Order_InvoicingSubType__c, /*?*/

CASE
	WHEN acc.TemplateLanguage__c  = 'fr' /*LocaleSidKey__c => TemplateLanguage__c*/ 
	THEN
		/*Translation Fr*/
		replace(
			replace(
				replace(
					replace(
						replace(
                            replace(
                                replace(
                                    replace(
                                    ord.WorkTypeId,'Repair','Service (réparation)' /*Type__c => WorkTypeId, check values*/
                                    )
                                ,'5703','Vente'
                                )
                            ,'1st Ignition','Première verification'
                            )
						,'5706','Vente de pièces de rechange'
						)
					,'Maintenance','Entretien'
					)
				,'5708','Note de crédit'
				)
			,'5709','Invoice copy'
			)
		,'5711','Facture de contrat') 
	ELSE
		/*Translation NL*/
		replace(
			replace(
				replace(
					replace(
						replace(
                            replace(
                                replace(
                                    replace(
                                    ord.WorkTypeId,'Repair','Service reparatie' /*Type__c => WorkTypeId, check values*/
                                    )
                                ,'5703','Verkooporder'
                                )
                            ,'1st Ignition','Eerste nazicht'
                            )
						,'5706','Artikelverkoop service'
						)
					,'Maintenance','Onderhoud'
					)
				,'5708','Kredietnota'
				)
			,'5709','Factuur kopie'
			)
		,'5711','Factuur standaard contract') 
END
as Order_Type__c,

ord.Description as Order_Description__c, /*Description__c => Description*/
ord.CustomerTimeWindow__c as Order_CustomerTimeWindow__c,

CASE
	WHEN acc.TemplateLanguage__c IN ('fr', 'nl') /*LocaleSidKey__c => TemplateLanguage__c*/
	THEN
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
							ord.CustomerTimewindow__c,'12401','AT' /*?*/
							)
						,'12402','FC'
						)
					,'12403','LC'
					)
				,'12404','AM'
				)
			,'12405','PM'
			)
		,'12409','AT')
	ELSE ord.CustomerTimeWindow__c /*?*/
END
as TimeWindow,

ord.Status as Order_Status__c, /*Status__c => Status, check values*/

con.Id as Contract_Id,
con.Name as Contract_Name,
con.util_templatedetails__c as Contract_Util_templatedetails__c,

ite.Id as OrderItem_Id,
ite.ProductNameCalc__c as OrderItem_ProductNameCalc__c,

acc2.Id as OrderRole_Account__c,
acc2.Id as Recipient_Id,
acc2.Email__c as Recipient_Email,
acc2.AccountNumber as Recipient_AccountNumber,
acc2.Name as Recipient_Name,
case 
	when left(acc2.Phone,2) = '00' /*Phone__c => Phone, take from Recipient Account instead of OrderRole*/
		then
		replace(substring(acc2.Phone,3,len(acc2.Phone) - 2),' ','') /*Phone__c => Phone*/
	when left(rol.Phone__c,1) = '0' /*Phone__c => Phone*/
		then
		replace(substring(acc2.Phone,2,len(acc2.Phone) - 1),' ','') /*Phone__c => Phone*/
	when left(acc2.Phone,1) = '+' /*Phone__c => Phone*/
		then
		replace(substring(acc2.Phone,2,len(acc2.Phone) - 1),' ','') /*Phone__c => Phone*/
	else
		acc2.Phone /*Phone__c => Phone*/
end as Recipient_Phone,
case 
	when left(rol.MobilePhone__c,2) = '00'
		then
		replace(substring(rol.MobilePhone__c,3,len(rol.MobilePhone__c) - 2),' ','')
	when left(rol.MobilePhone__c,1) = '0'
		then
		replace(substring(rol.MobilePhone__c,2,len(rol.MobilePhone__c) - 1),' ','')
	when left(rol.MobilePhone__c,1) = '+'
		then
		replace(substring(rol.MobilePhone__c,2,len(rol.MobilePhone__c) - 1),' ','')
	else
		rol.MobilePhone__c
end as Recipient_MobilePhone__c,
loc.Address as Location_Address, /*OrderRole object => Location object, Street__c => Address, contains street name + house no*/
loc.Floor as Location_Floor, /*OrderRole object => Location object, Floor__c => Floor*/
loc.FlatNo as Location_FlatNo, /*OrderRole object => Location object, FlatNo__c => FlatNo*/
loc.PostalCode as Location_PostalCode, /*OrderRole object => Location object, PostalCode__c => PostalCode*/
loc.City as Location_City, /*OrderRole object => Location object, City__c => City*/

res.Id as Resource_Id,
res.AccountID as Resource_Account__c,
res.Name as Resource_Name,
res.FirstName__c as Resource_FirstName__c,
res.LastName__c as Resource_LastName__c,
res.EMail__c as Resource_EMail__c,

acc.PersonContactId as SubscriberKey,
acc.TemplateLanguage__c as Account_LocaleSidKey__c, /*LocaleSidkey__c => TemplateLanguage__c*/

ass.Name as Assignment_Name, /*Will 'OA-XXXXXXX' stay?*/
ROW_NUMBER ( ) OVER ( PARTITION BY app.Id ORDER BY app.ActualStartTime ASC ) AS RowNumber /*Start__c => ActualStartTime*/

FROM ENT.WorkOrder ord /*SCOrder__c => Work Order*/

INNER JOIN ENT.ServiceAppointment app on ord.Id = app.ParentRecordId /*Order__c => ParentRecordId*/
INNER JOIN ENT.Asset asset on asset.Id = ord.AssetId 
LEFT JOIN ENT.ServiceContract con on ord.ServiceContractId = con.Id /*Contract__c => ServiceContractId*/
LEFT JOIN ENT.Account acc on res.AccountID = acc.Id /*Account object for technician info, res.Account__c => res.AccountID */
LEFT JOIN ENT.Account acc2 on ord.Account = acc2.Id /*Account object for recipient info*/
LEFT JOIN ENT.Assigned Resource ass on app.Id = ass.ServiceAppointment /*SCAssignment => Assigned Resource object*/
INNER JOIN ENT.Service Resource res on ass.ServiceResource = res.Id

WHERE

convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.ActualStartTime) /*Start__c => ActualStartTime*/
AND app.Country = 'BE' /*Country__c => Country*/
AND res.Name NOT LIKE 'Dummy%'
AND ord.Status = 'In Progress' /*Status__c => Status, old values ('5502', '5503', '5509', '5510') all become 'In Progress' value, check Excel mapping field*/
AND app.Status != '5507' /*AssignmentStatus__c => Status, check values ee Excel*/

ORDER BY app.Start__c ASC

)
AS Sub
WHERE RowNumber =1
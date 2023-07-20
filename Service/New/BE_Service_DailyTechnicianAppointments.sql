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

OrderRole_Account__c,
Recipient_Id,
Recipient_Email,
Recipient_AccountNumber,
OrderRole_Name1__c,
OrderRole_Phone__c,
OrderRole_MobilePhone__c,
OrderRole_Street__c,
OrderRole_HouseNo__c,
OrderRole_Floor__c,
OrderRole_FlatNo__c,
OrderRole_PostalCode__c,
OrderRole_City__c,

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
ord.Closed__c as Order_Closed__c,
ord.InvoicingSubType__c as Order_InvoicingSubType__c,

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
                                    ord.WorkTypeId,'5701','Service (réparation)' /*Type__c => WorkTypeId, check values*/
                                    )
                                ,'5703','Vente'
                                )
                            ,'5705','Première verification'
                            )
						,'5706','Vente de pièces de rechange'
						)
					,'5707','Entretien'
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
                                    ord.WorkTypeId,'5701','Service reparatie' /*Type__c => WorkTypeId, check values*/
                                    )
                                ,'5703','Verkooporder'
                                )
                            ,'5705','Eerste nazicht'
                            )
						,'5706','Artikelverkoop service'
						)
					,'5707','Onderhoud'
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

rol.Account__c as OrderRole_Account__c,
rol.OrderRole__c as OrderRole_OrderRole__c,
acc2.Id as Recipient_Id,
acc2.Email__c as Recipient_Email,
acc2.AccountNumber as Recipient_AccountNumber,
rol.Order__c as OrderRole_Order__c,
rol.Name1__c as OrderRole_Name1__c,
case 
	when left(rol.Phone__c,2) = '00'
		then
		replace(substring(rol.Phone__c,3,len(rol.Phone__c) - 2),' ','')
	when left(rol.Phone__c,1) = '0'
		then
		replace(substring(rol.Phone__c,2,len(rol.Phone__c) - 1),' ','')
	when left(rol.Phone__c,1) = '+'
		then
		replace(substring(rol.Phone__c,2,len(rol.Phone__c) - 1),' ','')
	else
		rol.Phone__c
end as OrderRole_Phone__c,
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
end as OrderRole_MobilePhone__c,
/*rol.MobilePhone__c as OrderRole_MobilePhone__c,*/
/*rol.Phone__c as OrderRole_Phone__c,*/
rol.Street__c as OrderRole_Street__c,
rol.HouseNo__c as OrderRole_HouseNo__c,
rol.Floor__c as OrderRole_Floor__c,
rol.FlatNo__c as OrderRole_FlatNo__c,
rol.PostalCode__c as OrderRole_PostalCode__c,
rol.City__c as OrderRole_City__c,

res.Id as Resource_Id,
res.Account__c as Resource_Account__c,
res.Name as Resource_Name,
res.FirstName__c as Resource_FirstName__c,
res.LastName__c as Resource_LastName__c,
res.EMail__c as Resource_EMail__c,

acc.PersonContactId as SubscriberKey,
acc.LocaleSidKey__c as Account_LocaleSidKey__c,

ass.Name as Assignment_Name,
ROW_NUMBER ( ) OVER ( PARTITION BY app.Id ORDER BY app.Start__c ASC ) AS RowNumber

FROM ENT.WorkOrder ord /*SCOrder__c => Work Order*/

INNER JOIN ENT.ServiceAppointment app on ord.Id = app.ParentRecordId /*Order__c => ParentRecordId*/
INNER JOIN ENT.SCResource__c_Salesforce_3 res on app.Resource__c = res.Id
INNER JOIN ENT.SCOrderItem__c_Salesforce_4 ite on app.OrderItem__c = ite.Id
INNER JOIN ENT.SCOrderRole__c_Salesforce_2 rol on app.Order__c = rol.Order__c
LEFT JOIN ENT.ServiceContract con on ord.ServiceContractId = con.Id /*Contract__c => ServiceContractId*/
LEFT JOIN ENT.Account acc on res.AccountId = acc.Id /*Account object for technician info, res.Account__c => res.AccountId */
LEFT JOIN ENT.Account acc2 on ord.Account = acc2.Id /*Account object for recipient info*/
LEFT JOIN ENT.SCAssignment__c_Salesforce_2 ass on ord.Id = ass.Order__c

WHERE

convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.ActualStartTime) /*Start__c => ActualStartTime*/
AND app.Country = 'BE' /*Country__c => Country*/
AND res.Name NOT LIKE 'Dummy%'
AND ord.Status__c IN ('5502', '5503', '5509', '5510') /*Status__c => Status, check values see Excel*/
/* AND rol.OrderRole__c = '50301' /*Maybe free to delete*/ */
AND app.AssignmentStatus__c != '5507' /*AssignmentStatus__c => Status, check values ee Excel*/

ORDER BY app.Start__c ASC

)
AS Sub
WHERE RowNumber =1
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
Order_Type__c,
Order_Closed__c,
Order_Description__c,
Order_CustomerTimeWindow__c,
TimeWindow,
Order_InvoicingSubType__c,
Order_Status__c,
Order_BrandName__c,

Contract_Name,
Contract_Util_templatedetails__c,
Contract_IdExt__c,
Contract_Frame__c,
InScope,


OrderItem_ProductNameCalc__c,

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
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.Start__c))) as StartTime,
convert(varchar(5),CONVERT(time, CONVERT(varchar,CONVERT(date, getdate()))+ DATEADD(hh, 8, app.End__c))) as EndTime,
app.Start__c as Appointment_Start__c,
app.TimeWindow__c as Appointment_TimeWindow__c,
app.AssignmentStatus__c as Appointment_AssignmentStatus__c,

ord.Id as Order_Order__c,
ord.Contract__c as Order_Contract__c,
ord.Closed__c as Order_Closed__c,
ord.InvoicingSubType__c as Order_InvoicingSubType__c,

CASE
	WHEN acc.LocaleSidKey__c  = 'fr' 
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
                                    ord.Type__c,'5701','Service (réparation)'
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
                                    ord.Type__c,'5701','Service reparatie'
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

ord.Description__c as Order_Description__c,
ord.CustomerTimeWindow__c as Order_CustomerTimeWindow__c,

CASE
	WHEN acc.LocaleSidKey__c IN ('fr', 'nl')
	THEN
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
							ord.CustomerTimewindow__c,'12401','AT'
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
	ELSE ord.CustomerTimeWindow__c
END
as TimeWindow,

ord.Status__c as Order_Status__c,
ord.BrandName__c as Order_BrandName__c,

con.Id as Contract_Id,
con.Name as Contract_Name,
con.util_templatedetails__c as Contract_Util_templatedetails__c,
con.IdExt__c as Contract_IdExt__c,
con.Frame__c as Contract_Frame__c,

CASE 
    WHEN (con.Frame__c IN ('a0C1r00003pBl9xEAC', 'a0C1r00003pBn8fEAC', 'a0C1r00003pBnc1EAC', 'a0C1r00003pAp8fEAC', 'a0C1r000042mBBuEAM', 'a0C6900004FDg8cEAD', 'a0C1r000043BCxWEAW', 'a0C1r00004AWdHDEA1', 'a0C69000048JyyFEAS', 'a0C6900004NgIJoEAN', 'a0C1r00003w47NVEAY', 'a0Cw000001GNm6qEAD', 'a0C6900004O0WqtEAF', 'a0C6900004DiveKEAR', 'a0C1r00003xRltxEAC')) THEN 'False'
    ELSE 'True'
END AS InScope,

ite.Id as OrderItem_Id,
ite.ProductNameCalc__c as OrderItem_ProductNameCalc__c,

rol.Account__c as OrderRole_Account__c,
rol.LocaleSidKey__c as OrderRole_LocaleSidKey__c,
acc2.Id as Recipient_Id,
acc2.Email__c as Recipient_Email,
acc2.AccountNumber as Recipient_AccountNumber,
acc2.LocaleSidKey__c as Recipient_Language,
rol.OrderRole__c as OrderRole_OrderRole__c,
rol.Order__c as OrderRole_Order__c,
rol.Name1__c as OrderRole_Name1__c,
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
ROW_NUMBER ( ) OVER ( PARTITION BY app.Id ORDER BY app.Start__c ASC ) AS RowNumber,
Dense_Rank() OVER (PARTITION BY acc2.Id, rol.Street__c, rol.MobilePhone__c, acc2.Email__c ORDER BY app.Start__c ASC) AS AmountOfAppointments


FROM ENT.SCOrder__c_Salesforce_2 ord

INNER JOIN ENT.SCAppointment__c_Salesforce_2 app on ord.Id = app.Order__c
INNER JOIN ENT.SCResource__c_Salesforce_3 res on app.Resource__c = res.Id
INNER JOIN ENT.SCOrderItem__c_Salesforce_4 ite on app.OrderItem__c = ite.Id
INNER JOIN ENT.SCOrderRole__c_Salesforce_2 rol on app.Order__c = rol.Order__c
LEFT JOIN ENT.SCContract__c_Salesforce_5 con on ord.Contract__c = con.Id
LEFT JOIN ENT.Account_Salesforce_2 acc on res.Account__c = acc.Id
LEFT JOIN ENT.Account_Salesforce_2 acc2 on rol.Account__c = acc2.Id
LEFT JOIN ENT.SCAssignment__c_Salesforce_2 ass on ord.Id = ass.Order__c
LEFT JOIN ENT.SCInstalledBase__c_Salesforce_5 ib on ib.Id = ite.InstalledBase__c

WHERE

convert(int,dateadd(day,convert(float,getdate()), 1))=convert(int,app.Start__c)
AND app.Country__c = 'BE'
AND res.Name NOT LIKE 'Dummy%'
AND ord.Status__c IN ('5502', '5503', '5509', '5510')
AND rol.OrderRole__c = '50301'
AND app.AssignmentStatus__c != '5507'

ORDER BY app.Start__c ASC

)
AS Sub
WHERE RowNumber = 1
AND AmountOfAppointments = 1
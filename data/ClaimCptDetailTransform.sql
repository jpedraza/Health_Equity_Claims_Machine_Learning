select 
	cb.NewMemberID,
	cdb.CPTCode,
	CASE 
		WHEN PatientResponsibilityAmount = 'NULL'
			THEN '0'
		ELSE PatientResponsibilityAmount
	END as PatientResponsibilityAmount,
	RepricedAmount,
	ClaimType,
	ServiceStart,
	cast(ServiceEnd as datetime2) as ServiceEnd
from dbo.ClaimBASE cb 
join dbo.ClaimDetailBASE cdb
	on cb.NewClaimID = cdb.NewClaimID
where PatientResponsibilityAmount is not null and 
	  PatientResponsibilityAmount != ''
order by cb.NewMemberID ASC, ServiceEnd ASC

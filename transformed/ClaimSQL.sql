select 
	cast(cb.NewMemberID as int) as NewMemberID,
	cast(d.DependentID as int) as DependentID,
	cdb.CPTCode,
	ccs.[ CcsCode],
	CASE 
		WHEN PatientResponsibilityAmount = 'NULL'
			THEN '0'
		ELSE cast(PatientResponsibilityAmount as float)
	END as PatientResponsibilityAmount,
	cast(RepricedAmount as float) as RepricedAmount,
	case
		when d.BirthYear = 'NULL'
			then 0
		else cast(d.BirthYear as int)
	end as BirthYear,
	d.Gender,
	m.Zip,
	m.State,
	ClaimType,
	ServiceStart,
	cast(ServiceEnd as datetime2) as ServiceEnd
into #tempTransformed2
from dbo.Claim cb 
join dbo.ClaimDetail cdb
	on cb.NewClaimID = cdb.NewClaimID
join dbo.Dependent d
	on cb.NewMemberID = d.NewMemberID
join dbo.Member m
	on m.NewMemberID = cb.NewMemberID
join dbo.CptToCssDict ccs
	on ccs.CPTCode = cdb.CPTCode
where PatientResponsibilityAmount is not null and 
	  PatientResponsibilityAmount != ''
order by cb.NewMemberID ASC, ServiceEnd ASC

select NewMemberID, DependentID, max(ServiceEnd) as LastServiceEnd
into #tempTransformed3
from #tempTransformed2
group by NewMemberID, DependentID
order by NewMemberID, DependentID

select tt2.NewMemberID, tt2.DependentID, tt2.BirthYear, tt2.State, CPTCode as LastCPTCode, CachedBalance, cast(0 as float) as RecommendedBalance, 0 as SufficientAmount, ServiceEnd
into dbo.NewMemberBalancePredictions
from #tempTransformed2 tt2
	join #tempTransformed3 tt3
		on tt2.ServiceEnd = tt3.LastServiceEnd and tt2.NewMemberID = tt3.NewMemberID and tt2.DependentID = tt3.DependentID
	join dbo.Balance b
		on cast(tt2.NewMemberID as varchar(50)) = b.NewMemberID
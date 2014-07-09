drop temporary table tCardPrintsCountDay;
create temporary table tCardPrintsCountDay as
select cast(w.ACTION_DATE as date) as PrintDay
	  ,w.client_user_id
	  ,count(*) as PrintCount
	  ,0 as StoresCount
	  ,'NOT KNOWN' as Store
from segment.wallet_action_protocol w
where w.action = 'COUPONCALL'
group by cast(w.ACTION_DATE as date)
	    ,w.client_user_id;

update tCardPrintsCountDay 
set StoresCount = ifnull((select count(distinct r1.client_store_id) 
                   from segment.receipt_data r1
                   join segment.receiptdata_report r2 on r1.report_id = r2.id
				   where r2.RETAILER_ID = 3
				   and tCardPrintsCountDay.client_user_id = r1.CLIENT_USER_ID
				   and tCardPrintsCountDay.PrintDay = cast(r1.purchase_time as date)
				   and r1.client_store_id is not null
				  ), 0);


select * from tCardPrintsCountDay limit 50;

update tCardPrintsCountDay 
set Store = (select r1.client_store_id
			 from segment.receipt_data r1
			 join segment.receiptdata_report r2 on r1.report_id = r2.id
			 where r2.RETAILER_ID = 3
			 and tCardPrintsCountDay.client_user_id = r1.CLIENT_USER_ID
			 and tCardPrintsCountDay.PrintDay = cast(r1.purchase_time as date)
			 and r1.client_store_id is not null
			 limit 1
		    )
where StoresCount = 1;

delete from KPIsByDay where KPIName = 'Repeaters Print Sparschein';
delete from KPIsByCalendarWeek where KPIName = 'Repeaters Print Sparschein';
delete from KPIsByMonth where KPIName = 'Repeaters Print Sparschein';


# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,PrintDay
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountDay
where PrintCount > 1
group by PrintDay;


# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,PrintDay
	  ,ifnull(Store, '_NULL_')
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountDay
where PrintCount > 1
group by PrintDay
	    ,ifnull(Store, '_NULL_');


create temporary table tCardPrintsCountCW as
select case
		when week(PrintDay, 3) = 1 then CONCAT(YEAR(PrintDay) + MONTH(PrintDay) div 12, '-W01')
		when week(PrintDay, 3) >= 51 and MONTH(PrintDay) = 1 then CONCAT((YEAR(PrintDay)-1), '-W', right(100+week(PrintDay, 3),2))
		else CONCAT(YEAR(PrintDay), '-W', right(100+week(PrintDay, 3),2))
	   end as KPI_WEEK
	  ,client_user_id
	  ,sum(PrintCount) as PrintCount
	  ,count(distinct Store) as StoresCount
	  ,'NOT KNOWN' as Store
from tCardPrintsCountDay
group by case
		  when week(PrintDay, 3) = 1 then CONCAT(YEAR(PrintDay) + MONTH(PrintDay) div 12, '-W01')
		  when week(PrintDay, 3) >= 51 and MONTH(PrintDay) = 1 then CONCAT((YEAR(PrintDay)-1), '-W', right(100+week(PrintDay, 3),2))
		  else CONCAT(YEAR(PrintDay), '-W', right(100+week(PrintDay, 3),2))
	     end
	    ,client_user_id;

update tCardPrintsCountCW
set Store = (select t.Store
			 from tCardPrintsCountDay t
			 where t.client_user_id = tCardPrintsCountCW.CLIENT_USER_ID
			 and case when week(t.PrintDay, 3) = 1 then CONCAT(YEAR(t.PrintDay) + MONTH(t.PrintDay) div 12, '-W01')
					  when week(t.PrintDay, 3) >= 51 and MONTH(t.PrintDay) = 1 then CONCAT((YEAR(t.PrintDay)-1), '-W', right(100+week(t.PrintDay, 3),2))
					  else CONCAT(YEAR(t.PrintDay), '-W', right(100+week(t.PrintDay, 3),2))
				 end = tCardPrintsCountCW.KPI_WEEK
			 limit 1
		    )
where StoresCount = 1;


# total
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,KPI_Week
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountCW
where PrintCount > 1
group by KPI_Week;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountCW
where PrintCount > 1
group by KPI_Week
	    ,ifnull(Store, '_NULL_');




create temporary table tCardPrintsCountMonth as
select date_format(PrintDay, '%Y.%m') as KPI_MONTH
	  ,client_user_id
	  ,sum(PrintCount) as PrintCount
	  ,count(distinct Store) as StoresCount
	  ,'NOT KNOWN' as Store
from tCardPrintsCountDay
group by date_format(PrintDay, '%Y.%m')
	    ,client_user_id;

update tCardPrintsCountMonth
set Store = (select t.Store
			 from tCardPrintsCountDay t
			 where t.client_user_id = tCardPrintsCountMonth.CLIENT_USER_ID
			 and date_format(t.PrintDay, '%Y.%m') = tCardPrintsCountMonth.KPI_MONTH
			 limit 1
		    )
where StoresCount = 1;


# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,KPI_MONTH
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountMonth
where PrintCount > 1
group by KPI_MONTH;

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Repeaters Print Sparschein' as KPIName 
	  ,KPI_MONTH
	  ,ifnull(Store, '_NULL_')
	  ,Count(distinct client_user_id) as Val
from tCardPrintsCountMonth
where PrintCount > 1
group by KPI_MONTH
	    ,ifnull(Store, '_NULL_');

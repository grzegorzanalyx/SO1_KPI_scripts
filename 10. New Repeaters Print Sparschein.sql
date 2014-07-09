delete from KPIsByDay where KPIName = 'New Repeaters Print Sparschein';
delete from KPIsByCalendarWeek where KPIName = 'New Repeaters Print Sparschein';
delete from KPIsByMonth where KPIName = 'New Repeaters Print Sparschein';



# total day
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'New Repeaters Print Sparschein' as KPIName 
      ,t.kpi_day
	  ,count(*)
from (
select cast(ACTION_DATE as date) as KPI_DAY
	  ,client_user_id
	  ,count(*) as PrintCount
from segment.wallet_action_protocol
where action = 'COUPONCALL'
group by cast(ACTION_DATE as date)
	    ,client_user_id
having count(*) > 0
) t
group by t.kpi_day;

# total cw
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'New Repeaters Print Sparschein' as KPIName 
      ,t.kpi_day
	  ,count(*)
from (
select case
		when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
		when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
		else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
	   end as KPI_DAY
	  ,client_user_id
	  ,count(*) as PrintCount
from segment.wallet_action_protocol
where action = 'COUPONCALL'
group by case
		  when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
		  when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
		  else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
	     end
	    ,client_user_id
having count(*) > 0
) t
group by t.kpi_day;

#total month
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'New Repeaters Print Sparschein' as KPIName 
      ,t.kpi_day
	  ,count(*)
from (
select date_format(action_date, '%Y.%m') as KPI_DAY
	  ,client_user_id
	  ,count(*) as PrintCount
from segment.wallet_action_protocol
where action = 'COUPONCALL'
group by date_format(action_date, '%Y.%m')
	    ,client_user_id
having count(*) > 0
) t
group by t.kpi_day;
drop temporary table if exists tBasketsRaw;
create temporary table tBasketsRaw as
select t.Store
	  ,t.client_user_id
	  ,cast(t.purchase_time as date) as KPI_Day
	  ,Count(*) as BasketCount
      ,0 as NumberOfPrintsUpToThisDay
from (
SELECT distinct client_store_id as Store
	  ,CASH_REGISTER_ID
      ,PURCHASE_TIME
      ,CLIENT_BASKET_ID
	  ,client_user_id
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3) t
group by t.Store
	    ,t.client_user_id
	    ,cast(t.purchase_time as date);


#create index ix_UserDate on segment.wallet_action_protocol (client_user_id, action_date);
update tBasketsRaw
set NumberOfPrintsUpToThisDay = (select count(*) 
							     from segment.wallet_action_protocol w
							     where w.action = 'COUPONCALL'
							     and w.client_user_id = tBasketsRaw.client_user_id
								 and cast(w.ACTION_DATE as date) <= tBasketsRaw.KPI_Day);

delete from KPIsByDay where KPIName = 'Penetration Repeaters Print';
delete from KPIsByCalendarWeek where KPIName = 'Penetration Repeaters Print';
delete from KPIsByMonth where KPIName = 'Penetration Repeaters Print';

insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,KPI_Day
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by KPI_Day
having sum(BasketCount) > 0;


insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,KPI_Day
	  ,ifnull(Store, '_NULL_')
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by KPI_Day, ifnull(Store, '_NULL_')
having sum(BasketCount) > 0;



insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,case when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
			when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
			else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by case when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
			  when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
			  else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
having sum(BasketCount) > 0;


insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,case when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
			when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
			else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end
	  ,ifnull(Store, '_NULL_')
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by case when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
			  when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
			  else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end, ifnull(Store, '_NULL_')
having sum(BasketCount) > 0;


insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,date_format(kpi_day, '%Y.%m')
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by date_format(kpi_day, '%Y.%m')
having sum(BasketCount) > 0;


insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Penetration Repeaters Print' as KPIName 
      ,date_format(kpi_day, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,sum(case when NumberOfPrintsUpToThisDay > 1 then BasketCount else 0 end) / sum(BasketCount)
from tBasketsRaw
group by date_format(kpi_day, '%Y.%m'), ifnull(Store, '_NULL_')
having sum(BasketCount) > 0;
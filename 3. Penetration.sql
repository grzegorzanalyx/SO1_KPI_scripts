drop temporary table if exists tBasketnPenetration;
create temporary table tBasketnPenetration as
select t.Store
	  ,cast(t.purchase_time as date) as KPI_Day
	  ,count(*) as BasketsTotal
	  ,sum(t.UserNotNull) as BasketsWithCard
from (
SELECT distinct client_store_id as Store
	  ,CASH_REGISTER_ID
      ,PURCHASE_TIME
      ,CLIENT_BASKET_ID
      ,case when client_user_id is null then 0 else 1 end as UserNotNull
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
) t
group by t.Store
	    ,cast(t.purchase_time as date)
having count(*) > 0;

#select * from tBasketnPenetration;

delete from KPIsByDay where KPIName = 'Penetration';
delete from KPIsByCalendarWeek where KPIName = 'Penetration';
delete from KPIsByMonth where KPIName = 'Penetration';


# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Penetration' as KPIName 
	  ,KPI_DAY
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by KPI_Day;

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Penetration' as KPIName 
	  ,KPI_Day
	  ,ifnull(Store, '_NULL_')
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by KPI_Day
	    ,ifnull(Store, '_NULL_');





insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Penetration' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Penetration' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
	    ,ifnull(Store, '_NULL_');



# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Penetration' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by date_format(KPI_Day, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Penetration' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,sum(BasketsWithCard) / sum(BasketsTotal) as Val
from tBasketnPenetration
group by date_format(KPI_Day, '%Y.%m')
	    ,ifnull(Store, '_NULL_');
drop temporary table if exists tBasketsRaw;
create temporary table tBasketsRaw as
select t.Store
	  ,t.client_user_id
	  ,cast(t.purchase_time as date) as KPI_Day
	  ,Count(*) as BasketCount
from (
SELECT distinct client_store_id as Store
	  ,CASH_REGISTER_ID
      ,PURCHASE_TIME
      ,CLIENT_BASKET_ID
      ,client_user_id
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and client_user_id is not null
) t
group by t.Store
	    ,t.client_user_id
	    ,cast(t.purchase_time as date);
create index ixBaskets on tBasketsRaw (store, client_user_id, kpi_day);


delete from KPIsByDay where KPIName = 'Repeater Users ExtraKarte';
delete from KPIsByCalendarWeek where KPIName = 'Repeater Users ExtraKarte';
delete from KPIsByMonth where KPIName = 'Repeater Users ExtraKarte';

drop temporary table if exists tBasketsCumulDay;
create temporary table tBasketsCumulDay as
select KPI_Day
	  ,store
	  ,client_user_id
	  ,0 as BasketsCumulative
from tBasketsRaw;


update tBasketsCumulDay
set BasketsCumulative = (select sum(BasketCount) from tBasketsRaw t 
                         where t.kpi_day <= tBasketsCumulDay.kpi_day
						 and t.store = tBasketsCumulDay.store
						 and t.client_user_id = tBasketsCumulDay.client_user_id
					    );

#select * from tBasketsCumulDay order by BasketsCumulative desc limit 100;


# total
drop temporary table if exists tDayGlobal;
create temporary table tDayGlobal as
select distinct KPI_Day
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tDayGlobal
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t where t.kpi_day <= tDayGlobal.KPI_Day and t.BasketsCumulative > 1);

insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,UsersWithRepeats as Val
from tDayGlobal;


# by store
drop temporary table if exists tDayGlobalStore;
create temporary table tDayGlobalStore as
select distinct KPI_Day
	  ,store
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tDayGlobalStore
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t where t.kpi_day <= tDayGlobalStore.KPI_Day and t.store = tDayGlobalStore.store and t.BasketsCumulative > 1);

insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,ifnull(Store, '_NULL_')
	  ,UsersWithRepeats as Val
from tDayGlobalStore;







# total
drop temporary table if exists tCWGlobal;
create temporary table tCWGlobal as
select distinct case
		when week(kpi_day, 3) = 1 then CONCAT(YEAR(kpi_day) + MONTH(kpi_day) div 12, '-W01')
		when week(kpi_day, 3) >= 51 and MONTH(kpi_day) = 1 then CONCAT((YEAR(kpi_day)-1), '-W', right(100+week(kpi_day, 3),2))
		else CONCAT(YEAR(kpi_day), '-W', right(100+week(kpi_day, 3),2))
	   end as KPI_Day
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tCWGlobal
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t 
						where case
							   when week(t.kpi_day, 3) = 1 then CONCAT(YEAR(t.kpi_day) + MONTH(t.kpi_day) div 12, '-W01')
							   when week(t.kpi_day, 3) >= 51 and MONTH(t.kpi_day) = 1 then CONCAT((YEAR(t.kpi_day)-1), '-W', right(100+week(t.kpi_day, 3),2))
							   else CONCAT(YEAR(t.kpi_day), '-W', right(100+week(t.kpi_day, 3),2))
							  end <= tCWGlobal.KPI_Day and t.BasketsCumulative > 1);

insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,UsersWithRepeats as Val
from tCWGlobal;


# by store
drop temporary table if exists tCWGlobalStore;
create temporary table tCWGlobalStore as
select distinct case
		when week(kpi_day, 3) = 1 then CONCAT(YEAR(kpi_day) + MONTH(kpi_day) div 12, '-W01')
		when week(kpi_day, 3) >= 51 and MONTH(kpi_day) = 1 then CONCAT((YEAR(kpi_day)-1), '-W', right(100+week(kpi_day, 3),2))
		else CONCAT(YEAR(kpi_day), '-W', right(100+week(kpi_day, 3),2))
	   end as KPI_Day
	  ,store
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tCWGlobalStore
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t 
						where case
							   when week(t.kpi_day, 3) = 1 then CONCAT(YEAR(t.kpi_day) + MONTH(t.kpi_day) div 12, '-W01')
							   when week(t.kpi_day, 3) >= 51 and MONTH(t.kpi_day) = 1 then CONCAT((YEAR(t.kpi_day)-1), '-W', right(100+week(t.kpi_day, 3),2))
							   else CONCAT(YEAR(t.kpi_day), '-W', right(100+week(t.kpi_day, 3),2))
							  end <= tCWGlobalStore.KPI_Day and t.store = tCWGlobalStore.store and t.BasketsCumulative > 1);

insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,ifnull(Store, '_NULL_')
	  ,UsersWithRepeats as Val
from tCWGlobalStore;









# total
drop temporary table if exists tMonthGlobal;
create temporary table tMonthGlobal as
select distinct date_format(kpi_day, '%Y.%m') as kpi_day
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tMonthGlobal
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t 
                        where date_format(t.kpi_day, '%Y.%m') <= tMonthGlobal.KPI_Day and t.BasketsCumulative > 1);

insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,UsersWithRepeats as Val
from tMonthGlobal;


# by store
drop temporary table if exists tMonthGlobalStore;
create temporary table tMonthGlobalStore as
select distinct date_format(kpi_day, '%Y.%m') as kpi_day
	  ,store
	  ,0 as UsersWithRepeats
from tBasketsCumulDay;

update tMonthGlobalStore
set UsersWithRepeats = (select count(distinct t.client_user_id) from tBasketsCumulDay t 
                        where date_format(t.kpi_day, '%Y.%m') <= tMonthGlobalStore.KPI_Day and t.store = tMonthGlobalStore.store and t.BasketsCumulative > 1);

insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Repeater Users ExtraKarte' as KPIName 
	  ,KPI_DAY
	  ,ifnull(Store, '_NULL_')
	  ,UsersWithRepeats as Val
from tMonthGlobalStore;



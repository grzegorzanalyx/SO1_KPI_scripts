

create temporary table tBudgetValues as
select cast(r1.PURCHASE_TIME as date) as KPI_DAY
	  ,r1.CLIENT_STORE_ID as Store
	  ,c.COUPON_INFORMATION_ID
	  ,ci.BRAND
	  ,r1.VALUE_SALES
	  ,ci.TAX
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
left join segment.coupon c on c.id = r1.coupon_id
join segment.coupon_information ci on c.COUPON_INFORMATION_ID = ci.ID
where r2.RETAILER_ID = 3
and coupon_id is not null;

/*
select count(distinct coupon_id) from segment.receipt_data;
select count(id) from segment.coupon;
*/

delete from KPIsByDay where KPIName = 'Budget Spent';
delete from KPIsByCalendarWeek where KPIName = 'Budget Spent';
delete from KPIsByMonth where KPIName = 'Budget Spent';

# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_DAY
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day;

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(Store, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
	    ,ifnull(Store, '_NULL_');

# by brand
insert into KPIsByDay(KPIName, KPIDay, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
	    ,ifnull(BRAND, '_NULL_');

# by coupon_info
insert into KPIsByDay(KPIName, KPIDay, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and brand
insert into KPIsByDay(KPIName, KPIDay, StoreID, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
		,ifnull(STORE, '_NULL_')
	    ,ifnull(BRAND, '_NULL_');

# by store and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by brand and coupon_info
insert into KPIsByDay(KPIName, KPIDay, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store, brand and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,KPI_Day
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by KPI_Day
		,ifnull(STORE, '_NULL_')
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');






insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
	    ,ifnull(Store, '_NULL_');

# by brand
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
	    ,ifnull(BRAND, '_NULL_');

# by coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and brand
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(BRAND, '_NULL_');

# by store and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by brand and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store, brand and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	     end
		,ifnull(STORE, '_NULL_')
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');











# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
	    ,ifnull(Store, '_NULL_');

# by brand
insert into KPIsByMonth(KPIName, KPIMonth, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
	    ,ifnull(BRAND, '_NULL_');

# by coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and brand
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, BrandID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(BRAND, '_NULL_');

# by store and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by brand and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store, brand and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, BRANDID, CampaignID, KPIValue)
select 'Budget Spent' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(BRAND, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,sum(VALUE_SALES / ((100+TAX)/100)) / 100 as Val
from tBudgetValues
group by date_format(KPI_Day, '%Y.%m')
		,ifnull(STORE, '_NULL_')
		,ifnull(BRAND, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


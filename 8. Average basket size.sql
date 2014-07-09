
create index ix_BaskedIndex on segment.receipt_data (PURCHASE_TIME, CLIENT_STORE_ID, CASH_REGISTER_ID, CLIENT_BASKET_ID);

drop temporary table tBasketSizes;
create temporary table tBasketSizes as
select r1.PURCHASE_TIME
	  ,r1.CLIENT_STORE_ID as Store
	  ,r1.CASH_REGISTER_ID 
	  ,r1.CLIENT_BASKET_ID
	  ,c.COUPON_INFORMATION_ID
	  ,max(case when r1.client_user_id is null then 0 else 1 end) as ExtraCardUsed
	  ,sum(case when r1.COUPON_ID is null then 1 else 0 end) as ItemCount
	  ,sum(case when r1.coupon_id is null then VALUE_SALES else -VALUE_SALES end) as BasketValue
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
left join segment.coupon c on c.id = r1.coupon_id
where r2.RETAILER_ID = 3
group by r1.PURCHASE_TIME
	    ,r1.CLIENT_STORE_ID 
		,r1.CASH_REGISTER_ID 
	    ,r1.CLIENT_BASKET_ID
	    ,c.COUPON_INFORMATION_ID;


select * from tBasketSizes where ExtraCardUsed = 0 limit 20;


delete from KPIsByDay where KPIName = 'Average basket size total';
delete from KPIsByCalendarWeek where KPIName = 'Average basket size total';
delete from KPIsByMonth where KPIName = 'Average basket size total';
delete from KPIsByDay where KPIName = 'Average basket size with card';
delete from KPIsByCalendarWeek where KPIName = 'Average basket size with card';
delete from KPIsByMonth where KPIName = 'Average basket size with card';

delete from KPIsByDay where KPIName = 'Average basket value total';
delete from KPIsByCalendarWeek where KPIName = 'Average basket value total';
delete from KPIsByMonth where KPIName = 'Average basket value total';
delete from KPIsByDay where KPIName = 'Average basket value with card';
delete from KPIsByCalendarWeek where KPIName = 'Average basket value with card';
delete from KPIsByMonth where KPIName = 'Average basket value with card';



# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Average basket size total' as KPIName 
	  ,cast(purchase_time as date)
	  ,avg(itemcount) as Val
from tBasketSizes
group by cast(purchase_time as date);

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by cast(purchase_time as date)
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByDay(KPIName, KPIDay, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by cast(purchase_time as date)
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by cast(purchase_time as date)
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');





insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Average basket size total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,avg(itemcount) as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');






# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Average basket size total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,avg(itemcount) as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, CampaignID, KPIValue)
select 'Average basket size total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');



#-------------- with cards --------------------------------------------------------



# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date);

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByDay(KPIName, KPIDay, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');





insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');






# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, CampaignID, KPIValue)
select 'Average basket size with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(itemcount) as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');




#----------- now basket values --------------------------------------------------



# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Average basket value total' as KPIName 
	  ,cast(purchase_time as date)
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by cast(purchase_time as date);

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by cast(purchase_time as date)
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByDay(KPIName, KPIDay, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by cast(purchase_time as date)
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by cast(purchase_time as date)
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');





insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Average basket value total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');






# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Average basket value total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, CampaignID, KPIValue)
select 'Average basket value total' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
group by date_format(purchase_time, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');



#-------------- with cards --------------------------------------------------------



# total
insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date);

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByDay(KPIName, KPIDay, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByDay(KPIName, KPIDay, StoreID, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,cast(purchase_time as date)
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by cast(purchase_time as date)
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');





insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');

# by store and coupon_info
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end KPI_Week
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by case
		when week(purchase_time, 3) = 1 then CONCAT(YEAR(purchase_time) + MONTH(purchase_time) div 12, '-W01')
		when week(purchase_time, 3) >= 51 and MONTH(purchase_time) = 1 then CONCAT((YEAR(purchase_time)-1), '-W', right(100+week(purchase_time, 3),2))
		else CONCAT(YEAR(purchase_time), '-W', right(100+week(purchase_time, 3),2))
	   end
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');






# total
insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m');

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(Store, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(Store, '_NULL_');

# by coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');


# by store and coupon_info
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, CampaignID, KPIValue)
select 'Average basket value with card' as KPIName 
	  ,date_format(purchase_time, '%Y.%m')
	  ,ifnull(STORE, '_NULL_')
	  ,ifnull(COUPON_INFORMATION_ID, '_NULL_')
	  ,avg(BasketValue)/100 as Val
from tBasketSizes
where ExtraCardUsed > 0
group by date_format(purchase_time, '%Y.%m')
		,ifnull(STORE, '_NULL_')
	    ,ifnull(COUPON_INFORMATION_ID, '_NULL_');
create temporary table tRedemptionDoubleDay as
select t.KPI_DAY
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select cast(r1.PURCHASE_TIME as date) as KPI_DAY
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by cast(r1.PURCHASE_TIME as date)
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select cast(action_date as date) as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by cast(action_date as date)) t2 on t.KPI_DAY = t2.PrintDate
group by t.KPI_DAY
	    ,t2.SparscheinsPrinted;

create temporary table tRedemptionDoubleDayStore as
select t.KPI_DAY
	  ,t.Store
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select cast(r1.PURCHASE_TIME as date) as KPI_DAY
	  ,r1.CLIENT_STORE_ID as Store
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by cast(r1.PURCHASE_TIME as date)
	    ,r1.CLIENT_STORE_ID
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select cast(action_date as date) as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by cast(action_date as date)) t2 on t.KPI_DAY = t2.PrintDate
group by t.KPI_DAY
	    ,t.Store
	    ,t2.SparscheinsPrinted;

delete from KPIsByDay where KPIName = 'Redemption Rate "Sparschein"';

insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_DAY
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleDay;

# by store
insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_Day
	  ,ifnull(Store, '_NULL_')
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleDayStore;


#--------------------------------------------------------------------------------------------

create temporary table tRedemptionDoubleWeek as
select t.KPI_WEEK
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select case
		when week(r1.PURCHASE_TIME, 3) = 1 then CONCAT(YEAR(r1.PURCHASE_TIME) + MONTH(r1.PURCHASE_TIME) div 12, '-W01')
		when week(r1.PURCHASE_TIME, 3) >= 51 and MONTH(r1.PURCHASE_TIME) = 1 then CONCAT((YEAR(r1.PURCHASE_TIME)-1), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		else CONCAT(YEAR(r1.PURCHASE_TIME), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
	   end as KPI_WEEK
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by case
		  when week(r1.PURCHASE_TIME, 3) = 1 then CONCAT(YEAR(r1.PURCHASE_TIME) + MONTH(r1.PURCHASE_TIME) div 12, '-W01')
		  when week(r1.PURCHASE_TIME, 3) >= 51 and MONTH(r1.PURCHASE_TIME) = 1 then CONCAT((YEAR(r1.PURCHASE_TIME)-1), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		  else CONCAT(YEAR(r1.PURCHASE_TIME), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		 end
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select case
			  when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
			  when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
			  else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
			 end as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by case
			    when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
			    when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
				else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
			   end) t2 on t.KPI_WEEK = t2.PrintDate
group by t.KPI_WEEK
	    ,t2.SparscheinsPrinted;

create temporary table tRedemptionDoubleWeekStore as
select t.KPI_WEEK
	  ,t.Store
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select case
		when week(r1.PURCHASE_TIME, 3) = 1 then CONCAT(YEAR(r1.PURCHASE_TIME) + MONTH(r1.PURCHASE_TIME) div 12, '-W01')
		when week(r1.PURCHASE_TIME, 3) >= 51 and MONTH(r1.PURCHASE_TIME) = 1 then CONCAT((YEAR(r1.PURCHASE_TIME)-1), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		else CONCAT(YEAR(r1.PURCHASE_TIME), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
	   end as KPI_WEEK
	  ,r1.CLIENT_STORE_ID as Store
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by case
		  when week(r1.PURCHASE_TIME, 3) = 1 then CONCAT(YEAR(r1.PURCHASE_TIME) + MONTH(r1.PURCHASE_TIME) div 12, '-W01')
		  when week(r1.PURCHASE_TIME, 3) >= 51 and MONTH(r1.PURCHASE_TIME) = 1 then CONCAT((YEAR(r1.PURCHASE_TIME)-1), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		  else CONCAT(YEAR(r1.PURCHASE_TIME), '-W', right(100+week(r1.PURCHASE_TIME, 3),2))
		 end
	    ,r1.CLIENT_STORE_ID
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select case
			  when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
			  when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
			  else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
			 end as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by case
			    when week(action_date, 3) = 1 then CONCAT(YEAR(action_date) + MONTH(action_date) div 12, '-W01')
			    when week(action_date, 3) >= 51 and MONTH(action_date) = 1 then CONCAT((YEAR(action_date)-1), '-W', right(100+week(action_date, 3),2))
				else CONCAT(YEAR(action_date), '-W', right(100+week(action_date, 3),2))
			   end) t2 on t.KPI_WEEK = t2.PrintDate
group by t.KPI_WEEK
	    ,t.Store
	    ,t2.SparscheinsPrinted;

delete from KPIsByCalendarWeek where KPIName = 'Redemption Rate "Sparschein"';

insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_Week
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleWeek;

# by store
insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleWeekStore;


#--------------------------------------------------------------------------------------------

create temporary table tRedemptionDoubleMonth as
select t.KPI_WEEK
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select date_format(r1.purchase_time, '%Y.%m') as KPI_WEEK
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by date_format(r1.purchase_time, '%Y.%m')
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select date_format(action_date, '%Y.%m') as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by date_format(action_date, '%Y.%m')) t2 on t.KPI_WEEK = t2.PrintDate
group by t.KPI_WEEK
	    ,t2.SparscheinsPrinted;

create temporary table tRedemptionDoubleMonthStore as
select t.KPI_WEEK
	  ,t.Store
	  ,count(*) as CardWithMoreThanOneCouponRedeemed
	  ,t2.SparscheinsPrinted
from (
select date_format(r1.purchase_time, '%Y.%m') as KPI_WEEK
	  ,r1.CLIENT_STORE_ID as Store
	  ,r1.CLIENT_USER_ID
	  ,count(*) as CouponsRedeemed
from segment.receipt_data r1
join segment.receiptdata_report r2 on r1.report_id = r2.id
where r2.RETAILER_ID = 3
and coupon_id is not null
group by date_format(r1.purchase_time, '%Y.%m')
	    ,r1.CLIENT_STORE_ID
		,r1.CLIENT_USER_ID
having count(*) > 1
) t
join (select date_format(action_date, '%Y.%m') as PrintDate
			,count(distinct CLIENT_USER_ID) as SparscheinsPrinted
	  from segment.wallet_action_protocol
	  where ACTION = 'COUPONCALL'
	  group by date_format(action_date, '%Y.%m')) t2 on t.KPI_WEEK = t2.PrintDate
group by t.KPI_WEEK
	    ,t.Store
	    ,t2.SparscheinsPrinted;

delete from KPIsByMonth where KPIName = 'Redemption Rate "Sparschein"';

insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_Week
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleMonth;

# by store
insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Redemption Rate "Sparschein"' as KPIName 
	  ,KPI_Week
	  ,ifnull(Store, '_NULL_')
	  ,CardWithMoreThanOneCouponRedeemed / SparscheinsPrinted as Val
from tRedemptionDoubleMonthStore;


# KPI 1 - number of new clients per day / week / month

select cast(CREATION_DATE as date) as 'DATE'
      ,count(distinct client_user_id) as 'CLIENT_COUNT'
from segment.wallet_status_information
group by cast(CREATION_DATE as date)
order by 1;

select concat(date_format(CREATION_DATE, '%Y.'), week(CREATION_DATE, 3)) as 'YEAR.WEEK'
      ,count(distinct client_user_id) as 'CLIENT_COUNT'
from segment.wallet_status_information
group by concat(date_format(CREATION_DATE, '%Y.'), week(CREATION_DATE, 3)) 
order by 1;

select date_format(CREATION_DATE, '%Y.%m') as 'YEAR.MONTH'
      ,count(distinct client_user_id) as 'CLIENT_COUNT'
from segment.wallet_status_information
group by date_format(CREATION_DATE, '%Y%m')
order by 1;


/*
select week(STR_TO_DATE(20071231, '%Y%m%d'), 3);
select STR_TO_DATE(20071231, '%Y%m%d')
	  ,case
		when week(STR_TO_DATE(20071231, '%Y%m%d'), 3) = 1 then CONCAT(YEAR(STR_TO_DATE(20071231, '%Y%m%d')) + MONTH(STR_TO_DATE(20071231, '%Y%m%d')) div 12, '-W01')
		when week(STR_TO_DATE(20071231, '%Y%m%d'), 3) >= 51 and MONTH(STR_TO_DATE(20071231, '%Y%m%d')) = 1 then CONCAT((YEAR(STR_TO_DATE(20071231, '%Y%m%d'))-1), '-W', right(100+week(STR_TO_DATE(20071231, '%Y%m%d'), 3),2))
		else CONCAT(YEAR(STR_TO_DATE(20071231, '%Y%m%d')), '-W', right(100+week(STR_TO_DATE(20071231, '%Y%m%d'), 3),2))
	   end
*/

/*
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
create function reporting.fISOWEEK(_date date) returns text
begin
	declare res text;
	select case
					when week(_date, 3) = 1 then CONCAT(YEAR(_date) + MONTH(_date)/12, '-W01')
					when week(_date, 3) >= 51 and MONTH(_date) = 1 then CONCAT((YEAR(_date)-1), '-W', right(100+week(_date, 3),2))
					else CONCAT(YEAR(_date), '-W', right(100+week(_date, 3),2))
				 end
	into res;
	return res;
end$$
DELIMITER ;
*/

create index ix_ReceiptCard on segment.receipt_data (CLIENT_USER_ID);
create temporary table tCardStoreDate as
select cast(w.CREATION_DATE as date) as KPI_Day
	  ,(select r1.CLIENT_STORE_ID 
        from segment.receipt_data r1 
		join segment.receiptdata_report r2 on r1.report_id = r2.id
        where r1.client_user_id = w.client_user_id 
		and r2.RETAILER_ID = 3
		order by r1.purchase_time
		limit 1) as Store
from segment.wallet_status_information w;

delete from KPIsByDay where KPIName = 'Users';
delete from KPIsByCalendarWeek where KPIName = 'Users';
delete from KPIsByMonth where KPIName = 'Users';


insert into KPIsByDay(KPIName, KPIDay, KPIValue)
select 'Users' as KPIName 
	  ,KPI_Day
	  ,count(*) as Count
from tCardStoreDate
group by KPI_Day;


insert into KPIsByDay(KPIName, KPIDay, StoreID, KPIValue)
select 'Users' as KPIName 
	  ,KPI_Day
	  ,Store
	  ,count(*) as Count
from tCardStoreDate
group by KPI_Day
	    ,Store;



insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, KPIValue)
select 'Users' as KPIName 
	  ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,count(*) as Count
from tCardStoreDate
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end;


insert into KPIsByCalendarWeek(KPIName, KPICalendarWeek, StoreID, KPIValue)
select 'Users' as KPIName 
      ,case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end KPI_Week
	  ,Store
	  ,count(*) as Count
from tCardStoreDate
group by case
		when week(KPI_Day, 3) = 1 then CONCAT(YEAR(KPI_Day) + MONTH(KPI_Day) div 12, '-W01')
		when week(KPI_Day, 3) >= 51 and MONTH(KPI_Day) = 1 then CONCAT((YEAR(KPI_Day)-1), '-W', right(100+week(KPI_Day, 3),2))
		else CONCAT(YEAR(KPI_Day), '-W', right(100+week(KPI_Day, 3),2))
	   end
	  ,STORE;



insert into KPIsByMonth(KPIName, KPIMonth, KPIValue)
select 'Users' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,count(*) as Count
from tCardStoreDate
group by date_format(KPI_Day, '%Y.%m');


insert into KPIsByMonth(KPIName, KPIMonth, StoreID, KPIValue)
select 'Users' as KPIName 
	  ,date_format(KPI_Day, '%Y.%m')
	  ,Store
	  ,count(*) as Count
from tCardStoreDate
group by date_format(KPI_Day, '%Y.%m')
	    ,Store;
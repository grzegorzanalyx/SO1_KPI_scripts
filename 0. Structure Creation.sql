DELIMITER $$
create function reporting.fISOWEEK(_date date) returns text
DETERMINISTIC
READS SQL DATA
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


DROP TABLE IF EXISTS KPIsByDay;
create table KPIsByDay (
    KPIName text
   ,KPIDay date
   ,CampaignID text
   ,StoreID text
   ,BrandID text
   ,KPIValue float
);


DROP TABLE IF EXISTS KPIsByCalendarWeek;
create table KPIsByCalendarWeek (
	KPIName text
   ,KPICalendarWeek text
   ,CampaignID text
   ,StoreID text
   ,BrandID text
   ,KPIValue float
);

DROP TABLE IF EXISTS KPIsByMonth;
create table KPIsByMonth (
	KPIName text
   ,KPIMonth text
   ,CampaignID text
   ,StoreID text
   ,BrandID text
   ,KPIValue float
);

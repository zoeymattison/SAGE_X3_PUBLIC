 ( ITMREF_0 , QTY_0 ) As 
select ITMREF_0 as ITMREF_0, COUNT(LOC_0) as QTY_0 from STOCK
group by ITMREF_0

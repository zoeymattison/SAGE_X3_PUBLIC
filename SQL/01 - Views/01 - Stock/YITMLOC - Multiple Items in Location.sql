 ( LOC_0 , QTY_0 ) As 
select LOC_0 as LOC_0, COUNT(ITMREF_0) as QTY_0 from STOCK
group by LOC_0

 ( SOHNUM_0 , QTY_0 ) As 
select SOHNUM_0 as SOHNUM, coalesce(sum(ORITYP_0),0)as QTY from SORDER
LEFT outer join STOPRED on SORDER.SOHNUM_0 = STOPRED.ORINUM_0
group by SOHNUM_0

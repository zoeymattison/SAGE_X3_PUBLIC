 ( SOHNUM_0 , SOPLIN_0 , ITMREF_0 , QTY_0 ) As 
select SOHNUM_0, SOPLIN_0, ITMREF_0, QTY_0 from SORDERQ 
where 
ALLQTY_0>0 and STOFCY_0='DC30'
group by SOHNUM_0, SOPLIN_0,ITMREF_0, QTY_0
having (select count(SOHNUM_0) from SDELIVERYD where SDELIVERYD.SOHNUM_0=SORDERQ.SOHNUM_0 and SHIDAT_0>=dateadd(d,-5,getdate()))>0

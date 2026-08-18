 ( TYP_0 , VCR_0 , DES_0 ) As 
select distinct TYP_0, NUM_0, DES_0 from XINFED where LINTYP_0<>2 and CREDATTIM_0>getdate()-4

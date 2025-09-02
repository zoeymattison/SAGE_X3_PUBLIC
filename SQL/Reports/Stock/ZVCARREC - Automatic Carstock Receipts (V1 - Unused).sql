select
right(d.BPCORD_0,4) as [Receiving Site],
format(getdate(), 'yyyyMMdd') as [Accounting Date],
iif(left(d.STOFCY_0,2)='DC','I'+d.STOFCY_0,d.STOFCY_0) as [Supplier Site],
d.SDHNUM_0 as [Delivery],
d.SDDLIN_0 as [Delivery Line],
d.ITMREF_0 as [Product],
d.ITMDES1_0 as [Description],
d.SAU_0 as [Unit of Measure],
d.QTY_0 as [Quantity Received],
isnull(p.PTHNUM_0,'')


from LIVE.SDELIVERYD d
inner join LIVE.SDELIVERYD s on d.SDHNUM_0=s.SDHNUM_0 and d.SDDLIN_0=s.SDDLIN_0
left join LIVE.PRECEIPTD p on d.SDHNUM_0=p.SDHNUM_0 and d.SDDLIN_0=p.SDDLIN_0
inner join LIVE.ITMMASTER i on d.ITMREF_0=i.ITMREF_0

select
d.ZRHNUM_0 as [Receipt Number],
d.RECFCY_0 as [Receiving Site],
format(getdate(), 'yyyyMMdd') as [Accounting Date],
iif(left(d.SUPFCY_0,2)='DC','I'+d.SUPFCY_0,d.SUPFCY_0) as [Supplier Site],
d.SDHNUM_0 as [Delivery],
d.SDDLIN_0 as [Delivery Line],
coalesce(q.POHNUM_0,'') as [Purchase Order],
coalesce(q.POPLIN_0,0) as [Purchase Line],
d.ITMREF_0 as [Product],
d.QTYUOM_0 as [Unit of Measure],
d.QTYRCP_0 as [Quantity Received],
s.SAUSTUCOE_0 as [Conversion],
i.STU_0 as [Stock Unit]


from LIVE.ZINTRD d
inner join LIVE.ZINTRH h on d.ZRHNUM_0=h.ZRHNUM_0
inner join LIVE.SDELIVERYD s on d.SDHNUM_0=s.SDHNUM_0 and d.SDDLIN_0=s.SDDLIN_0
left join LIVE.PRECEIPTD p on d.SDHNUM_0=p.SDHNUM_0 and d.SDDLIN_0=p.SDDLIN_0
left join LIVE.PORDERQ q on s.SOHNUM_0=q.LINOCNNUM_0 and s.SOPLIN_0=q.OCNLIN_0
inner join LIVE.ITMMASTER i on d.ITMREF_0=i.ITMREF_0

where (p.PTHNUM_0 is null) and d.LINSTA_0 in ('COMPLETE','SHORT') and QTYRCP_0>0 and EXPSTA_0<>2  and d.ZRHSTA_0=2
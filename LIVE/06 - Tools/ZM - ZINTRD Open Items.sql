select d.ZRHNUM_0,SUPFCY_0,RECFCY_0, ITMREF_0, LINSTA_0,SDHNUM_0,SDDLIN_0,QTYRCP_0,d.ZRHSTA_0,RECSTA_0 from LIVE.ZINTRD d
inner join LIVE.ZINTRH h on d.ZRHNUM_0=h.ZRHNUM_0

where SDHNUM_0+cast(SDDLIN_0 as varchar) not in (select SDHNUM_0+cast(SDDLIN_0 as varchar) from LIVE.PRECEIPTD) and LINSTA_0 in ('COMPLETE','SHORT') and QTYRCP_0>0 and d.ZRHSTA_0=2 --and RECFCY_0='2600'

order by RECFCY_0 asc,SDHNUM_0 asc,SDDLIN_0 asc
------------------------------------------------
select
z.SDHNUM_0,
z.LINSTA_0,
z.SDDLIN_0,
z.ITMREF_0,
r.PTHNUM_0


from LIVE.ZINTRD z
left join LIVE.PRECEIPTD r on z.SDHNUM_0=r.SDHNUM_0 and z.SDDLIN_0=r.SDDLIN_0

where r.PTHNUM_0 is null and z.QTYRCP_0>0 and z.LINSTA_0 in ('COMPLETE','SHORT')
-----
select
d.ZRHNUM_0 as [Receipt Number],
d.RECFCY_0 as [Receiving Site],
format(getdate(), 'yyyyMMdd') as [Accounting Date],
iif(left(d.SUPFCY_0,2)='DC','I'+d.SUPFCY_0,d.SUPFCY_0) as [Supplier Site],
d.SDHNUM_0 as [Delivery],
d.SDDLIN_0 as [Delivery Line],
d.ITMREF_0 as [Product],
d.QTYUOM_0 as [Unit of Measure],
d.QTYRCP_0 as [Quantity Received]


from LIVE.ZINTRD d
inner join LIVE.ZINTRH h on d.ZRHNUM_0=h.ZRHNUM_0
left join LIVE.PRECEIPTD p on d.SDHNUM_0=p.SDHNUM_0 and d.SDDLIN_0=p.SDDLIN_0

where (p.PTHNUM_0 is null) and d.LINSTA_0 in ('COMPLETE','SHORT') and QTYRCP_0>0 and EXPSTA_0<>2  and d.ZRHSTA_0=2
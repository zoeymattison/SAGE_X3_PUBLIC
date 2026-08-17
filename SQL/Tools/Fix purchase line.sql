/*
1. Remove the line from the purchase invoice
2. Try to remove the line from the receipt.
3. Delete the receipt line with SQL
4. Re-add the line to the PO.
5. Delete the old line from the purchase order P and Q tables.
6. Delete the old line from the cpt table using line number
*/

delete from LIVE.PRECEIPTD where PTHNUM_0='RECDC30217004' and ITMREF_0='HAM102269'
delete from LIVE.PORDERP where POHNUM_0='PO30089168' and ITMREF_0='HAM102269'
delete from LIVE.PORDERQ where POHNUM_0='PO30089168' and ITMREF_0='HAM102269'
delete from LIVE.CPTANALIN where VCRNUM_0='PO30089168' and VCRLIN_0=3000
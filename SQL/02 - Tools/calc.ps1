$src = (Get-ChildItem -Recurse -Filter *.src).Count
$sql = (Get-ChildItem -Recurse -Filter *.sql).Count
$total = $src + $sql

[PSCustomObject]@{
    "Sage X3 (Adonix 4GL)" = "$src files ($([math]::Round(($src/$total)*100, 1))%)"
    "T-SQL"                = "$sql files ($([math]::Round(($sql/$total)*100, 1))%)"
} | Format-List
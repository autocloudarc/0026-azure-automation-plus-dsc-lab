$avSetAds = "AvSetADS10"
$avSetDev = "AvSetDEV10"
$avSetLnx = "AvSetLNX10"
$avSetPki = "AvSetPKI10"
$avSetSql = "AvSetSQL10"
$avSetWeb = "AvSetWEB10"

$avSets = @{}
$avSets.Add("ads",$avSetAds)
$avSets.Add("dev",$avSetDev)
$avSets.Add("lnx",$avSetLnx)
$avSets.Add("pki",$avSetPki)
$avSets.Add("web",$avSetWeb)
$avSets.Add("sql",$avSetSql)

$avSetsPSObjectType = $avSets.GetType().Name
$avSetsPSObjectType

$avSetsJsonType = ($avSets | ConvertTo-Json).GetType().Name
$avSetsJsonType

$avSets.Values
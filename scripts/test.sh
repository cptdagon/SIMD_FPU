#!/bin/bash
#
#
##
echo "Lanes\t\t\tRC Effort low\t\t\t\t\tRC Effort high" > res.csv
echo "\tTreq\tFreq\tT(RC)\tArea(RC)\tT(Enc)\tArea(Enc)\tFreq\tT(RC)\tArea(RC)\tT(Enc)\tArea(Enc)" >> res.csv
##


#### high ####
grep "Total area of Chip" summaryReport.rpt > test.txt
var1=`awk '{print $5}' test.txt`
echo "$var1"


echo "$file"
grep "WNS (ns):" $file | tail -2 > test.txt
var4=`awk '{print $10}' test.txt`
echo "$var4" > test.txt
var6=$( tail -2  test.txt | head -1)
var7=$( tail -1  test.txt | head -1)
echo "$var6"
echo "$var7"


echo "$file"
grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " $file > test.txt
var5=`awk '{print $5}' test.txt`
echo "$var5" > test.txt
var8=$( tail -1  test.txt | head -1)
echo "$var8"

grep -A2 " Slack                                          Endpoint                                         Cost Group" $file > test.txt
var9=`awk '{print $1}' test.txt`
echo "$var9" > test.txt
var10=$( tail -1  test.txt | head -1)
echo "$var10"

#######################

echo "2	2.5	400					400	$var10	$var8	$var7	$var1" >> res.csv

#!/bin/bash
#
#
declare -i init_time
declare -i init_lanes
declare -i divmul_const
declare -i clock_time
declare -i input_time
declare -i new_lanes
declare -i prev_time
declare -i counter

iterations=$1
init_lanes=2 ## variable input
init_time=2500 ##time in pico seconds

divmul_const=2

gedit rtl/simd_fpu_pkg.vhd
gedit scripts/simd_fpu.rc

varhigh=high

counter=0

echo "Lanes				RC Effort low						RC Effort high" > res.csv
echo "	Treq	Freq	T(RC)	Area(RC)	T(Enc)	Area(Enc)	Freq	T(RC)	Area(RC)	T(Enc)	Area(Enc)" >> res.csv

rm rc.log
rm encounter.log
rm rc.cmd
rm encounter.logv
rm encounter.cmd

#*# loop content
while [  $counter -lt $1 ]; do

	clock_time=$init_time
	input_time=$(echo "$clock_time / $divmul_const" | bc)
	
	echo $init_lanes
	echo $clock_time
	echo $input_time
	echo $prev_time	
	
	sed -i "s/-effort low/-effort high/g" scripts/simd_fpu.rc
	sed -i -e "s/\(LANES : integer := \).*/\1$init_lanes;/" rtl/simd_fpu_pkg.vhd
	sed -i -e "s/\(define_clock -name clk -p \).*/\1$clock_time clk/" scripts/simd_fpu.rc
	sed -i "s/5000.0/$input_time.0/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### high ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var1=`awk '{print $5}' test.txt`
	echo "$var1"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var7=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var7"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var8=$( tail -1  test.txt | head -1)
	echo "$var8"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var10=$( tail -1  test.txt | head -1)
	echo "$var10"
	#########################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	sed -i "s/-effort high/-effort low/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### low ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var2=`awk '{print $5}' test.txt`
	echo "$var2"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var3=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var3"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var11=$( tail -1  test.txt | head -1)
	echo "$var11"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var12=$( tail -1  test.txt | head -1)
	echo "$var12"	
	#######################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	echo "2	2.5	400	$var12	$var11	$var3	$var2	400	$var10	$var8	$var7	$var1" >> res.csv
	#####################################################################################
	echo "##########\nPart 1/3 complete\n##########"
	##
	clock_time=$(echo "$clock_time * $divmul_const" |bc)
	prev_time=$input_time
	input_time=$(echo "$clock_time / $divmul_const" | bc)

	echo $init_lanes
	echo $clock_time
	echo $input_time
	echo $prev_time
	
	sed -i "s/-effort low/-effort high/g" scripts/simd_fpu.rc
	sed -i -e "s/\(LANES : integer := \).*/\1$init_lanes;/" rtl/simd_fpu_pkg.vhd
	sed -i -e "s/\(define_clock -name clk -p \).*/\1$clock_time clk/" scripts/simd_fpu.rc
	sed -i "s/$prev_time.0/$input_time.0/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### high ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var1=`awk '{print $5}' test.txt`
	echo "$var1"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var7=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var7"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var8=$( tail -1  test.txt | head -1)
	echo "$var8"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var10=$( tail -1  test.txt | head -1)
	echo "$var10"
	#########################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	sed -i -e "s/-effort high/-effort low/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### low ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var2=`awk '{print $5}' test.txt`
	echo "$var2"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var3=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var3"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var11=$( tail -1  test.txt | head -1)
	echo "$var11"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var12=$( tail -1  test.txt | head -1)
	echo "$var12"	
	#######################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	echo "2	2.5	400	$var12	$var11	$var3	$var2	400	$var10	$var8	$var7	$var1" >> res.csv
	#####################################################################################
	echo "##########\nPart 2/3 complete\n##########"
	##
	clock_time=$(echo "$clock_time * $divmul_const" | bc)
	prev_time=$input_time
	input_time=$(echo "$clock_time / $divmul_const" | bc)

	echo $init_lanes
	echo $clock_time
	echo $input_time
	echo $prev_time
	
	sed -i "s/-effort low/-effort high/g" scripts/simd_fpu.rc
	sed -i -e "s/\(LANES : integer := \).*/\1$init_lanes;/" rtl/simd_fpu_pkg.vhd
	sed -i -e "s/\(define_clock -name clk -p \).*/\1$clock_time clk/" scripts/simd_fpu.rc
	sed -i "s/$prev_time.0/$input_time.0/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### high ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var1=`awk '{print $5}' test.txt`
	echo "$var1"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var7=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var7"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var8=$( tail -1  test.txt | head -1)
	echo "$var8"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var10=$( tail -1  test.txt | head -1)
	echo "$var10"
	#########################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	sed -i "s/-effort high/-effort low/g" scripts/simd_fpu.rc

	rc -f scripts/simd_fpu.rc
	encounter -64 -init scripts/simd_fpu.enc
	
	#### low ####
	grep "Total area of Chip" summaryReport.rpt > test.txt
	var2=`awk '{print $5}' test.txt`
	echo "$var2"

	grep "WNS (ns):" encounter.log | tail -2 > test.txt
	var4=`awk '{print $10}' test.txt`
	echo "$var4" > test.txt
	var6=$( tail -2  test.txt | head -1)
	var3=$( tail -1  test.txt | head -1)
	echo "$var6"
	echo "$var3"

	grep -A2 "Instance  Cells  Cell Area  Net Area  Total Area " rc.log > test.txt
	var5=`awk '{print $5}' test.txt`
	echo "$var5" > test.txt
	var11=$( tail -1  test.txt | head -1)
	echo "$var11"

	grep -A2 " Slack                                          Endpoint                                         Cost Group" rc.log > test.txt
	var9=`awk '{print $1}' test.txt`
	echo "$var9" > test.txt
	var12=$( tail -1  test.txt | head -1)
	echo "$var12"	
	#######################
	rm rc.log
	rm encounter.log
	rm rc.cmd
	rm encounter.logv
	rm encounter.cmd
	
	echo "2	2.5	400	$var12	$var11	$var3	$var2	400	$var10	$var8	$var7	$var1" >> res.csv
	#####################################################################################
	echo "##########\nPart 3/3 complete\n##########"
	#####################################################################################
	echo "Iteration $counter Complete"
	init_lanes=$(echo "$init_lanes * $divmul_const" | bc)
	let counter=counter+1
done
#*# end loop content


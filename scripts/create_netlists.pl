#!/usr/bin/perl
use strict;
use warnings;

my $i, my $j;
my $RC_SCRIPT_FILE="scripts/simd_fpu.rc";
#my $RX_CLOCK_REPLACEMENT="s/define_clock -name clk -p \d+/ CACA";
my $LOCAL_SCRIPT="scripts/local.rc";
my $line;
my $inFileHandle;
my $outFileHandle;
my @script;
my $effortLoop;
# main loop

printf "Hello from perl\n";
printf ("Opening the %s script file\n",$RC_SCRIPT_FILE);

for ($effortLoop=0;$effortLoop<2;$effortLoop+=1)
{
    for ($i=2000;$i<=8000;$i+=2000)
    {
	
	open inFileHandle , "< $RC_SCRIPT_FILE" or die   "Error: Couldn't open $RC_SCRIPT_FILE\n";
	open outFileHandle , "> $LOCAL_SCRIPT" or die   "Error: Couldn't open $LOCAL_SCRIPT\n";
	@script=<inFileHandle>;
	close inFileHandle;
	
	for ($j=0;$j<$#script;$j++)
	{
	    chomp ($script[$j]);
# sort out clk, output files
	    $script[$j]=~ s/-p \d+/-p $i/; 
	    if ($effortLoop==0) {
		$script[$j]=~ s/-effort .+/-effort low/; 
	    }
	    else {
		$script[$j]=~ s/-effort .+/-effort high/; 
	    }

	    $script[$j]=~ s/simd_fpu.rc.v/simd_fpu.$i.$effortLoop.rc.v/; 
	    $script[$j]=~ s/simd_fpu.rc.sdc/simd_fpu.$i.$effortLoop.rc.sdc/; 

	    print (outFileHandle "$script[$j]\n");
	}
	my $RC_CMD_LINE="rc -f scripts/local.rc -logfile rc.$i.$effortLoop.log -overwrite";

	close outFileHandle;
	# Run rc
	system $RC_CMD_LINE;
	
    }   
}
exit;


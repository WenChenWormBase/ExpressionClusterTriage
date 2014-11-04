#!/usr/bin/perl -w
use strict;
use Ace;

my %paperInfo;
my $line;
my @tmp;

#--------- Read ecPaperList_merged.csv -------------------
open (LIST, "ecPaperList_merged.csv") || die "can't open $!";                    
while ($line=<LIST>) {
    chomp ($line);
    @tmp = split /\t/, $line;
    #print "$tmp[0] ---- $tmp[1]\n";
    $paperInfo{$tmp[0]} = $tmp[1];
}
close (LIST);

#-------------------- Look Up paper ids from submitted list ---------------
print "Which name list do you wish to search? ";			#enter the input file name
my $List_name = <stdin>;
chomp ($List_name);
my $output = join ".", $List_name, "out";

open (OUT, ">$output") || die "can't open $!";                         #open output file
open (IN, "$List_name") || die "can't open $!";				#open input file
while (my $line = <IN>) {
    chomp ($line);
    @tmp = split /\s+/, $line;
    foreach (@tmp) {
	if ($paperInfo{$_}) {
            print OUT "$_: $paperInfo{$_}\n";
        } else {
	    print OUT "$_: N.A.\n";
        }
    }
}
close (IN);
close (OUT);
print "Done.\n";

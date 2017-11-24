#!/usr/bin/perl -w
use strict;
use Ace;

my $tace='/usr/local/bin/tace';
my %paperInfo;
my $line;
my @tmp;
my $i = 0;
my @ecPaperList;

#get most up-to-date curated paper list of Expression_cluster and microarray
print "connecting to citace ...\n";
my $acedbpath='/home/citace/citace';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;
my $query="query find Paper Expression_cluster = * ";
my @ecPaperCurated=$db->find($query);
foreach (@ecPaperCurated) {
    if ($paperInfo{$_}) {
	#do nothing
    } else {
	$paperInfo{$_} = "Yes. Curated Expression Cluster.";
	$ecPaperList[$i] = $_;
	$i++;
    }
}
print "got expression cluster paper list. $i papers in list now.\n";

$query="query find Paper Microarray_experiment = * ";
my @mrPaperCurated=$db->find($query);
foreach (@mrPaperCurated) {
    if ($paperInfo{$_}) {
        $paperInfo{$_} = join "\|", $paperInfo{$_}, "Curated Microarray.";
    } else {
	$paperInfo{$_} = "Yes. Curated Microarray.";
	$ecPaperList[$i] = $_;
	$i++;
    }
}
$db->close();
print "got microarray paper list. $i papers in list now.\n";

#get most up-to-date curated paper list of SAGE, tiling array and RNAseq
print "connecting to WS ...\n";
$acedbpath='/home/citace/WS/acedb/';
$db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;
$query="query find Condition SAGE_experiment = * OR Analysis = RNAseq* OR Analysis = TAR* OR Analysis = MassSpec*; follow Reference";
my @otherCurated=$db->find($query);
foreach (@otherCurated) {
    if ($paperInfo{$_}) {
        $paperInfo{$_} = join "\|", $paperInfo{$_}, "Curated RNAseq/Tiling array/SAGE/Proteomics.";
    } else {
	$paperInfo{$_} = "Yes. Curated RNAseq/Tiling array/SAGE/Proteomics.";
	$ecPaperList[$i] = $_;
	$i++;
    }
}
$db->close();
print "got SAGE, Proteomics, Tiling array and RNAseq paper list. $i papers in list now.\n";

#get GEO microarray curation queue
print "Reading MAPaperGSETable ... \n";
open (IN1, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable.txt") || die "can't open $!"; 
while ($line=<IN1>) {
    chomp($line);
    if ($line =~ /^New/) {
	@tmp = split /\s+/, $line;
	if ($paperInfo{$tmp[1]}) {
	    $paperInfo{$tmp[1]} = join "\|", $paperInfo{$tmp[1]}, "Microarray on GEO curation list for Wen";
	} else {
	    $paperInfo{$tmp[1]} = "Yes. Microarray on curation list";
	    $ecPaperList[$i] = $tmp[1];
	    $i++;
	}	    
    }
}
close (IN1);
print "done. $i papers in list now.\n";

#get GEO RNAseq and tiling array curation queue
print "Reading MAPaperGSETable_RNAseq ... \n";
open (IN2, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable_RNAseq.txt") || die "can't open $!"; 
while ($line=<IN2>) {
    chomp($line);
    if ($line =~ /^New/) {
	@tmp = split /\s+/, $line;
	if ($paperInfo{$tmp[1]}) {
        $paperInfo{$tmp[1]} = join "\|", $paperInfo{$tmp[1]}, "RNAseq or tiling array on curation list";
	} else {
	    $paperInfo{$tmp[1]} = "Yes. RNAseq or tiling array on GEO curation list for Gary Williams";
	    $ecPaperList[$i] = $tmp[1];
	    $i++;
	}	    
    }
}
close (IN2);
print "done. $i papers in list now.\n";

#get expression cluster triage info
print "Reading ExprClusterTriage.csv ... \n";
open (IN3, "/home/wen/LargeDataSets/ExprCluster/ExprClusterTriage/ExprClusterTriage.csv") || die "can't open $!"; 
while ($line=<IN3>) {
    chomp($line);
    next unless $line =~ /^WBPaper/;
    @tmp = split /\t/, $line;
	if ($paperInfo{$tmp[0]}) {
	    #do nothing
	} else {

	    if ($tmp[1] ne "") { #Positive
		$paperInfo{$tmp[0]} = "Positive: $tmp[1]";
	    } elsif ($tmp[2] ne "") {#Negative
		$paperInfo{$tmp[0]} = "No: $tmp[2]";
	    } elsif ($tmp[3] ne "") {#Other spe
		$paperInfo{$tmp[0]} = "No: $tmp[3]";
	    } elsif ($tmp[4] ne "") {#Positive but not curatible
		$paperInfo{$tmp[0]} = "Positive but not curatible: $tmp[4]";
	    }

	    
#	    if ($tmp[2] ne "") { #SAGE
#		$paperInfo{$tmp[0]} = "Yes. SAGE: $tmp[2]";
#	    } elsif ($tmp[3] ne "") {#Protemoics
#		$paperInfo{$tmp[0]} = "Yes. Protemoics: $tmp[3]";
#	    } elsif ($tmp[4] ne "") {#RNAseq
#		$paperInfo{$tmp[0]} = "Yes. $tmp[4]";
#	    } elsif ($tmp[6] ne "") {#microarray
#		$paperInfo{$tmp[0]} = "Yes. $tmp[6]";
#	    } elsif ($tmp[5] ne "") {#qPCR
#		$paperInfo{$tmp[0]} = "Yes. qPCR: $tmp[5]";
#	    } elsif ($tmp[7] ne "") {#false positive
#		$paperInfo{$tmp[0]} = "No. False positive: $tmp[7]";
#	    } elsif ($tmp[8] ne "") {#other spe.
#		$paperInfo{$tmp[0]} = "No. Other species: $tmp[8]";
#	    } elsif ($tmp[9] ne "") {#positive but not curatible
#		$paperInfo{$tmp[0]} = "No. $tmp[8]";
#	    }

	    $ecPaperList[$i] = $tmp[0];
	    $i++;
	}	    
}
close (IN3);
print "done.  $i papers in list now.\n";


#get unchecked first pass list
print "Reading Unclassified_FirstPass.txt ... \n";
open (IN4, "/home/wen/LargeDataSets/ExprCluster/ExprClusterTriage/Unclassified_FirstPass.txt") || die "can't open $!"; 
while ($line=<IN4>) {
    next unless ($line =~ /WBPaper/);
    chomp($line);
    @tmp = split /\t/, $line;
    if ($paperInfo{$tmp[0]}) {
	    #do nothing
    } else {
	    $paperInfo{$tmp[0]} = "Yes. First pass not checked yet.";
	    $ecPaperList[$i] = $tmp[0];
	    $i++;
    }
}
close (IN4);
print "done. $i papers in list now.\n";

#get unchecked textpresso screen list
print "Reading Unclassified_Textpresso.txt ... \n";
open (IN5, "/home/wen/LargeDataSets/ExprCluster/ExprClusterTriage/Unclassified_Textpresso.txt") || die "can't open $!"; 
while ($line=<IN5>) {
    next unless ($line =~ /WBPaper/);
    chomp($line);
    @tmp = split /\s+/, $line;
    if ($paperInfo{$tmp[0]}) {
	    #do nothing
    } else {
	    $paperInfo{$tmp[0]} = "Textpresso hit = $tmp[1], not checked yet.";
	    $ecPaperList[$i] = $tmp[0];
	    $i++;
    }
}
close (IN5);
print "done. $i papers in list now.\n";

my $totalECpaper = $i;
#--- print out complate paper info list ------------
open (OUT, ">ecPaperList_merged.csv") || die "can't open $!";                         #open out
$i = 0;
my $e;
foreach $e (@ecPaperList) {
    if ($paperInfo{$e}) {
	print OUT "$e\t$paperInfo{$e}\n";
	$i++;
    } else {
	print "$e has no paper info.\n";
    }
}

print "Finished printing ecPaperList_merged.csv, $totalECpaper papers found, $i papers has paper info.\n";

#!/usr/bin/perl
use strict;
use File::Basename;

my ($final_list,$oseq_info) = @ARGV;

my %oseq_info;
open IN, "$oseq_info" or die;
<IN>;
while (<IN>){
	chomp;
	my @arr = split /\t/, $_;
	my $name = $arr[0];
	my $numbering = $arr[1];
	my $tumor_type = $arr[-4]; # 癌种: 泛癌种 / 肠癌
	$oseq_info{$name} = "$numbering\t$tumor_type";
}
close IN;

print "final表\t产品编号\t癌种\n";

open IN, "$final_list" or die;
while (<IN>){
	chomp;
	my $bn = basename($_);
	my $dn = dirname($_);
	my $name = (split /\_/, basename($dn))[0];
	my $numbering;
	if (exists $oseq_info{$name}){
		$numbering = $oseq_info{$name};
	}else{
		$numbering = "NA";
	}
	print "$bn\t$numbering\n";
}
close IN;
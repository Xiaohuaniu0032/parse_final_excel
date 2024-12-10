#!/usr/bin/perl
use strict;
use File::Basename;

my ($oseq_dir,$outfile) = @ARGV;

my @file = glob "$oseq_dir/*.parsed.xls";

open O, ">$outfile" or die;

my @final_file;
for my $file (@file){
	next if ($file =~ /SampleInfo/);
	push @final_file, $file;
}

# 输出header
my $ff = $final_file[0];
open IN, "$ff" or die;
my $h = <IN>;
close IN;
print O "$h";

for my $file (@final_file){
	open IN, "$file" or die;
	<IN>;
	my $info = <IN>;
	print O "$info";
	close IN;
}
close O;
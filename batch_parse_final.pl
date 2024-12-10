#!/usr/bin/perl
use File::Basename;

my ($oseq_list,$outdir) = @ARGV;
open O, ">run.sh" or die;
`chmod 755 run.sh`;

open IN, "$oseq_list" or die;
while (<IN>){
	chomp;
	my $dirname = dirname($_); # dirpath/22SSP2200008_分析结果
	my $name = (split /\_/, basename($dirname))[0]; # 22SSP2200008
	if (!-d "$outdir/$name"){
		`mkdir $outdir/$name`;
	}
	#print O "/home/fulongfei/miniconda3/bin/python3 /ehpcdata/fulongfei/git_repo/parse_final_excel/parse_oseq.py $_ $name $outdir/$name\n";
	print O "perl /ehpcdata/fulongfei/git_repo/parse_final_excel/parse_final.pl $_ $name $outdir/$name\n";
}
close IN;
close O;
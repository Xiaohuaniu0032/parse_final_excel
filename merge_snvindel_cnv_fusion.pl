#!/usr/bin/perl
use strict;
use File::Basename;

my ($indir) = @ARGV;


my @snvindel = glob "$indir/*filt_variation*";
my @cnv = glob "$indir/*final.CNV*";
my @fusion = glob "$indir/*filt_sv*";

# 检查文件个数
if (scalar(@snvindel) != 1 or scalar(@cnv) != 1 or scalar(@fusion) != 1){
	die "snv or cnv or fusion文件个数不唯一,请检查文件\n";
}


# snvindel
my $snvindel = $snvindel[0];

# get sample name
my $bn = basename($snvindel);
my $name = (split /\_/, basename($bn))[0];
my $outfile = "$indir/$name\.merged.annot.xls";
open O, ">$outfile" or die;
print O "sample_name\t体系基因\t体系检测结果p点\t体系检测结果c点\t体系基因亚区\t体系转录本\t体系突变丰度或拷贝数\t体系变异等级\t体系突变类型\n";

open IN, "$snvindel" or die;
<IN>;
while (<IN>) {
	# body...
	chomp;
	my @arr = split /\t/, $_;
	# 体系基因
	my $gene = $arr[1];
	# 体系检测结果c点
	my $cVar = $arr[2];
	# 体系检测结果p点
	my $pVar = $arr[3];

	my $new_cVar;
	if ($cVar =~ /&gt;/){
		my $ss = $cVar;
		$ss =~ s/&gt;/>/g;
		$new_cVar = $ss;
	}else{
		$new_cVar = $cVar;
	}

	my $Function = $arr[4];
	next if ($Function =~ /synon/);# coding-synon / synonymous_variant

	# 体系基因亚区 / ExIn_ID
	my $exon = $arr[13];
	# 体系转录本 / Transcript
	my $trans = $arr[34];
	# 体系突变丰度或拷贝数 / Case_var_freq
	my $mut_freq = $arr[5];
	# 体系变异等级 / 
	my $varType = "NA";
	
	# 体系突变类型 / 
	my $mut_type;
	if ($Function eq "missense"){
		$mut_type = "错义突变";
	}elsif ($Function eq "nonsense"){
		$mut_type = "无义突变";
	}elsif ($Function eq "frameshift"){
		$mut_type = "移码突变";
	}elsif ($Function eq "cds-del"){
		$mut_type = "缺失突变"; #del密码子是3的倍数
	}elsif ($Function eq "splice-5" or $Function eq "splice-3"){
		$mut_type = "剪切突变";
	}elsif ($Function eq "cds-ins"){
		$mut_type = "插入突变";
	}else{
		$mut_type = "其他";
	}

	print O "$name\t$gene\t$pVar\t$new_cVar\t$exon\t$trans\t$mut_freq\t$varType\t$mut_type\n";
}
close IN;


# cnv
my $cnv = $cnv[0];
my $cnv_line = (split /\s/, `wc -l $cnv`)[0];
if ($cnv_line >= 1){
	# 有cnv结果
	open IN, "$cnv" or die;
	<IN>;
	while (<IN>){
		chomp;
		my @arr = split /\t/, $_;
		my $gene = $arr[0];
		my $cnv_type = $arr[1]; # copy number gain / copy number loss
		my $CN = $arr[2];
		my $trans = $arr[3];
		
		my $cnv_type_chinese;
		if ($cnv_type eq "copy number gain"){
			$cnv_type_chinese = "拷贝数增加";
		}elsif ($cnv_type eq "copy number loss"){
			$cnv_type_chinese = "拷贝数减少";
		}else{
			$cnv_type_chinese = "其他";
		}

		# 体系变异等级 / 
		my $varType = "NA";
		
		print O "$name\t$gene\t$cnv_type_chinese\t-\t-\t$trans\t$CN\t$varType\t$cnv_type_chinese\n";
	}
	close IN;
}


#fusion
my $fusion = $fusion[0];
my $fusion_line = (split /\s/, `wc -l $fusion`)[0];
if ($fusion_line >= 1){
	# 有fusion结果
	open IN, "$fusion" or die;
	<IN>;
	while (<IN>){
		chomp;
		my @arr = split /\t/, $_;
		my $g1 = $arr[1];
		my $g2 = $arr[2];
		# 体系基因
		my $fs_gene = "$g1\-$g2";
		my $p_fs = "Fusion";

		# 体系基因亚区
		# exonIntrNum
		my $g1_reg = $arr[15]; # PARP1:IVS12
		# exonIntrNum2
		my $g2_reg = $arr[18]; # CORO2B:IVS1
		
		my $g1_ex = (split /\:/, $g1_reg)[1];
		my $g2_ex = (split /\:/, $g2_reg)[1];
		my $region = "$g1_ex\-$g2_ex"; # IVS12-IVS1

		# 体系转录本
		my $trans1 = $arr[13];
		my $trans2 = $arr[16];
		my $trans = "$trans1\-$trans2";

		# 体系突变丰度或拷贝数
		my $mut_freq = $arr[11];

		# 体系变异等级
		my $varType = "NA";

		# 体系突变类型
		my $mut_type = "融合变异";

		print O "$name\t$fs_gene\tFusion\t-\t$region\t$trans\t$mut_freq\t$varType\t$mut_type\n";
	}
	close IN;
}

close O;

#!/usr/bin/perl
use lib '/ehpcdata/fulongfei/perl_lib/lib/perl5';
use Spreadsheet::XLSX;


my ($final_file,$sample_name,$outdir) = @ARGV;

# Excel 文件路径
#my $excel_file = '/mnt/oseq_sample_export.xlsx';
my $excel_file = $ARGV[0];


# 创建Excel工作簿对象
my $excel = Spreadsheet::XLSX->new($excel_file);

# 检查工作簿是否成功打开
if (!$excel) {
    die "无法打开Excel文件: $excel_file\n";
}


my $log = "$outdir/$sample_name\.parse.log.xls";
open LOG, ">$log" or die;
    

foreach my $sheet (@{$excel->{Worksheet}}){
    # 对每个工作表进行操作
    my $sheet_name = $sheet->{Name};
    print "工作表名称: $sheet_name\n";
    print LOG "工作表名称: $sheet_name\n";

    my ($row_min, $row_max) = $sheet->row_range();
    my ($col_min, $col_max) = $sheet->col_range();

    print LOG "$row_min $row_max\n";
    print "$row_min $row_max\n";

    my $sample_sheet_file = "$outdir/$sample_name\_$sheet_name.final.parsed.xls";
    open O, ">$sample_sheet_file" or die;

    foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        #print "$row\n";
        my @row_data;
        foreach my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
            my $cell = $sheet->{Cells}[$row][$col];
            my $cell_value = $cell->{Val};
            #print "Row: $row, Col: $col, Value: $cell_value\n";
            push @row_data, $cell_value;
        }
        my $row_data = join "\t", @row_data;
        #print "$row_data\n";
        print O "$row_data\n";
    }
    close O;
}

close LOG;

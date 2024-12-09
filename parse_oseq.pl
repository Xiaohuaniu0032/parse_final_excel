#!/usr/bin/perl
use lib '/ehpcdata/fulongfei/perl_lib/lib/perl5';
use Spreadsheet::XLSX;


my ($oseq_file,$sample_name,$outdir) = @ARGV;

# Excel 文件路径
#my $excel_file = '/mnt/oseq_sample_export.xlsx';
my $excel_file = $ARGV[0];


# 创建Excel工作簿对象
my $excel = Spreadsheet::XLSX->new($excel_file);

# 检查工作簿是否成功打开
if (!$excel) {
    die "无法打开Excel文件: $excel_file\n";
}


foreach my $sheet (@{$excel->{Worksheet}}){
    # 对每个工作表进行操作
    my $sheet_name = $sheet->{Name};
    print "工作表名称: $sheet_name\n";

    my $sample_sheet_file = "$outdir/$sample_name\_$sheet_name.oseq.parsed.xls";
    open O, ">$sample_sheet_file" or die;

    for my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        my @row_data;
        for my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
            my $cell = $sheet->{Cells}[$row][$col];
            my $cell_value = $cell->{Val};
            #print "Row: $row, Col: $col, Value: $cell_value\n";
            push @row_data, $cell_value;
        }
        my $row_data = join "\t", @row_data;
        print O "$row_data\n";
    }
    close O;
}


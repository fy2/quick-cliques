use strict;
use warnings;
use feature 'say';

open my $fh,      '<', $ARGV[0]                or die "$!";
open my $fh_num,  '>', $ARGV[0] . '.compat'    or die "$!";
my %uniq_pairs;
my %samps;
while (<$fh>) {
    chomp;
    my $line = $_;
    my ( $sample1, $sample2, $compatible ) = split ',', $line;

    next if $compatible eq 'Not compatible';

    $samps{$sample1}++;
    $samps{$sample2}++;

    my @samples = sort ($sample1, $sample2);

    # uniq connected pairs:
    $uniq_pairs{ $samples[0] . ',' . $samples[1] }++;
}

my $i = 0;
my %trans;
my %back;
my @output;

foreach my $upair (keys %uniq_pairs) {
    my ($first, $second) = split ',', $upair;

    if (not exists $trans{$first} ) {
        $trans{$first} = $i;
        $back{$i} = $first;
        $i++;
    }

    my $first_num = $trans{$first};

    if (not exists $trans{$second} ) {
        $trans{$second} = $i;
        $back{$i} = $second;
        $i++;
    }

    my $second_num = $trans{$second};


    push @output, [$trans{$first}, $trans{$second}];
    push @output, [$trans{$second}, $trans{$first}];


}

say $fh_num scalar keys %samps;
say $fh_num scalar @output;

foreach my $pair ( sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @output )  {
    say $fh_num "$pair->[0],$pair->[1]";
}

close $fh_num;

#system("./bin/compdegen < $ARGV[0].compat");
system("./bin/qc --algorithm=tomita --input-file=$ARGV[0].compat > $ARGV[0].out 2>/dev/null");

open my $fh_out,  '<', "$ARGV[0].out" or die "$!";
open my $fh_back, '>', $ARGV[0] . '.clique.txt' or die "$!";
while(<$fh_out>) {
    chomp;
    my $line = $_;
    if ($line =~ /^\d/) {
        my @vertices = split ' ', $_;
        say $fh_back join ',',  map { $back{$_} if $back{$_} } @vertices;
    }
}
close $fh_out;
close $fh_back;
unlink "$ARGV[0].out";
unlink "$ARGV[0].compat";

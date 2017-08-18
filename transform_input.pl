use strict;
use warnings;
use feature 'say';

open my $fh, '<', $ARGV[0] or die "$!";

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
my @output;

foreach my $upair (keys %uniq_pairs) {
    my ($first, $second) = split ',', $upair;

    if (not exists $trans{$first} ) {
        $trans{$first} = $i;
        $i++;
    }

    my $first_num = $trans{$first};

    if (not exists $trans{$second} ) {
        $trans{$second} = $i;
        $i++;
    }

    my $second_num = $trans{$second};


    push @output, [$trans{$first}, $trans{$second}];
    push @output, [$trans{$second}, $trans{$first}];


}

say scalar keys %samps;
say scalar @output;

foreach my $pair ( sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @output )  {
    say "$pair->[0],$pair->[1]";
}


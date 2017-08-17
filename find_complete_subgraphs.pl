use strict;
use warnings;
use feature 'say';

open my $fh, '<', $ARGV[0] or die "$!";

my %trans;
my %back;
my %input;
my $i = 0;
while (<$fh>) {
    chomp;
    my $line = $_;
    my ( $sample1, $sample2, $compatible ) = split ',', $line;

    next if $compatible eq 'Not compatible';

    if ( not exists $trans{$sample1} ) {
        $i++;
        $trans{$sample1} = $i;
        $back{$i}        = $sample1;
    }

    if ( not exists $trans{$sample2} ) {
        $i++;
        $trans{$sample2} = $i;
        $back{$i}        = $sample2;
    }

    $input{ $trans{$sample1} . ',' . $trans{$sample2} }++;
    $input{ $trans{$sample2} . ',' . $trans{$sample1} }++;

}

say scalar keys %trans;
say scalar keys %input;
foreach my $key (
    sort {
        ( split( ',', $a ) )[0] <=> ( split( ',', $b ) )[0]
            || ( split( ',', $a ) )[1] <=> ( split( ',', $b ) )[1]
    } keys %input
    ) {
    say $key;
}


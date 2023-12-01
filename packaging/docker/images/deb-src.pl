#!/usr/bin/perl -w
#
# Modifies /etc/apt/sources.list to ensure that every deb line has a
# corresponding deb-src line.
#
use strict;

my @lines = ();
my @extra = ();
my %src = ();

open(SOURCES, '<', '/etc/apt/sources.list') or die;
foreach (<SOURCES>) {
    if (/^deb-src /) {
        $src{$_} = 1;
    } elsif (/^deb /) {
        my $alt = $_;
        $alt =~ s/^deb /deb-src / or die;
        push @extra, $alt;
    }
    push @lines, $_;
}
close(SOURCES);

open(SOURCES, '>', '/etc/apt/sources.list') or die;
foreach (@lines) {
    print SOURCES $_;
}
foreach (@extra) {
    defined $src{$_} or print SOURCES $_;
}
close(SOURCES);

exit 0;

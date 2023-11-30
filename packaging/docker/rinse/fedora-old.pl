#!/usr/bin/perl -w
#
# Attempt to extract a list of packages suitable for setting up a
# bare-bones Fedora system using rinse.
#
# This is ONLY intended for use with Fedora 25 or earlier.  For later
# Fedora releases, just use dnf repoquery with the --recursive option
# (as described in README.txt).
#
# This script should be run from within a virtual machine that already
# has the appropriate version of Fedora installed.
#
# - Ben Burton, 30 November 2023
#
use strict;

my @pkgs = ( 'dnf', 'fedora-release', 'basesystem', 'filesystem' );
my @latest = @pkgs;

my %all = ();
foreach (@pkgs) {
    $all{$_} = 1;
}

foreach my $target (@latest) {
    print("$target\n");
    my $info = `dnf repoquery --disablerepo fedora-source --requires --resolve '$target'`;
    foreach my $dep (split /^/, $info) {
        chomp $dep;
        $dep =~ /^\s*$/ and next;
        $dep =~ /^Last metadata/ and next;
        $dep =~ /^glibc-all-langpacks/ and next;
        $dep =~ /^glibc-langpack-/ and next;
        $dep =~ /^generic-release/ and next;
        $dep =~ /^(.*)-[^-]+-[^-]+$/ or die "$dep";
        $dep = $1;
        if (not defined $all{$dep}) {
            $all{$dep} = 1;
            push @latest, $dep;
        }
    }
}

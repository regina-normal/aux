#!/usr/bin/perl -w
#
# Attempt to extract a list of packages suitable for setting up a
# bare-bones openSUSE system using rinse.
#
# This script should be run from within a virtual machine that already
# has the appropriate version of openSUSE installed.
#
# - Ben Burton, 31 July 2021
#
use strict;

my @pkgs = ( 'rpm', 'zypper', 'util-linux', 'gzip', 'grep', 'sed', 'xz' );
my @latest = @pkgs;

my %deps = ();
my %all = ();
foreach (@pkgs) {
    $all{$_} = 1;
}

while ($#latest >= 0) {
    my @next = ();
    foreach my $target (@latest) {
        print("$target\n");
        my $info = `zypper --no-refresh info --requires '$target'`;
        if ($info =~ /^.*Requires\s*:\s*---\s*$/s) {
            next;
        } elsif ($info =~ /^.*Requires\s*:\s*\[\d+\]\n(.*)$/s) {
            $info = $1;
        } elsif ($info =~ /^.*Requires\s*:\s*([a-zA-Z0-9()\/._<>= -]+\n)\s*$/s) {
            $info = $1;
        } else {
            die "$info";
        }
        foreach my $dep (split /^/, $info) {
            chomp $dep;
            $dep =~ /^\s*$/ and next;
            $dep =~ s/^\s*(\S.*\S)\s*$/$1/;
            $dep =~ s/^\((.*) or busybox\)$/$1/;
            $dep =~ s/^\((compat-usrmerge-tools) or .*\)$/$1/;
            $dep =~ /^\(.* if systemd\)$/ and next;
            $dep =~ s/^(\S*) >= .*$/$1/;
            $dep =~ s/^(\S*) = .*$/$1/;
            if (defined $deps{$dep}) {
                # print("$target: $dep -> $deps{$dep} [seen]\n");
            } else {
                my $pkg = `rpm -q --whatprovides '$dep'`;
                chomp $pkg;
                $pkg =~ s/(.*)-.*?-.*?$/$1/g or die "$info -> $dep -> $pkg";
                $deps{$dep} = $pkg;
		# print("$target: $dep -> $pkg [new]\n");
                if (not defined $all{$pkg}) {
                    $all{$pkg} = 1;
                    push @latest, $pkg;
                }
            }
        }
    }
    @latest = @next;
}
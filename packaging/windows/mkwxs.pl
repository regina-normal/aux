#!/usr/bin/perl -w
use strict;

my $qtver = '5.12.3';
my $mingwver = '73';

open(TEMPLATE, '<', 'Regina.wxs.template') or die;
open(WXS, '>', 'Regina.wxs') or die;

my $msys;
my $mingw;
my $qt;
my $programfiles;

my $arch = `uname -m`;
chomp $arch;
if ($arch eq 'x86_64') {
    $msys = 'c:\msys64';
    $mingw = 'c:\msys64\mingw64';
    $qt = "c:\\Qt\\$qtver\\mingw${mingwver}_64";
    $programfiles = 'ProgramFiles64Folder';
} elsif ($arch eq 'i686') {
    $msys = 'c:\msys32';
    $mingw = 'c:\msys32\mingw32';
    $qt = "c:\\Qt\\$qtver\\mingw${mingwver}_32";
    $programfiles = 'ProgramFilesFolder';
} else {
    die "Unknown architecture: $arch";
}

my $line;
my $partial = '';
my @path = ();
my @exclude = ();
my $currPath = undef;
my $currExclude = {};
my ($name, $prefix, $suffix);
while (<TEMPLATE>) {
    s/\$msys/$msys/g;
    s/\$mingw/$mingw/g;
    s/\$qt/$qt/g;
    s/\$programfiles/$programfiles/g;

    />.*</ and die;

    if (not ($partial or /</)) {
        print WXS $_;
        next;
    }

    $partial .= $_;

    />/ or next;

    $line = $partial;
    $partial = '';

    if ($line =~ /<Directory.*FileSource='([^']*)'/s) {
        push @path, $currPath;
        push @exclude, $currExclude;
        $currPath = $1;
        $currExclude = {};
        print WXS "$line";
    } elsif ($line =~ /<Directory.*Name='([^']*)'/s) {
        push @path, $currPath;
        push @exclude, $currExclude;
        $currPath and $currPath .= "\\$1";
        $currExclude = {};
        print WXS "$line";
    } elsif ($line =~ /<\/Directory>/s) {
        $currPath = pop @path;
        $currExclude = pop @exclude;
        print WXS "$line";
    } elsif ($line =~ /<File.*Source='([^']*)'/s) {
        print WXS "$line";
    } elsif ($line =~ /^(.*<File.*Name=')([^']*)('.*)$/s) {
        $currPath or die;
        $prefix = $1;
        $name = $2;
        $suffix = $3;
        if ($name =~ '\*') {
            chdir $currPath or die "Could not chdir to $currPath";
            my @files = glob($name);
            @files or die "No files matching $name";
            # foreach (sort {CORE::fc($a) cmp CORE::fc($b)} @files) {
            foreach (sort @files) {
                $currExclude->{$_} and next;
                print WXS "$prefix$_$suffix";
            }
        } else {
            $currExclude->{$name} = 1;
            print WXS "$line";
        }
    } else {
        print WXS "$line";
    }
}

close(TEMPLATE);
close(WXS);

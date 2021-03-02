#!/usr/bin/perl -w
use strict;
use File::Copy qw(copy);
use File::Path qw(remove_tree);
use Cwd qw(cwd);

# ------------------------------------------------------------------------
# Begin manual configuration variables
#
# You should check and/or edit these before each build.
# ------------------------------------------------------------------------
my $regina_version = '6.0.2';
my $regina_build = '6.0.2.0';
my $qtver = '5.15.2';
my $mingwver = '81';
my $wixver = '3.11';
# my $srctree = '/home/bab/git/regina';
my $srctree = '/home/bab/software/regina-6.1';
my $installtree = '/home/bab/software';
# ------------------------------------------------------------------------
# End manual configuration variables
# ------------------------------------------------------------------------

# Constants and commands:
my $regina_wxs = 'Regina.wxs';
my @plugins = ( "platforms/qwindows.dll", "styles/qwindowsvistastyle.dll" );

my %major_commands = (
    'dlls' => 'update mingw/qt DLLs and plugins in the install tree (cleandlls + copydlls)',
    'msi' => 'all steps to create a full installer (mkwxs + mkmsi)',
);

my %minor_commands = (
    'mkwxs' => "build $regina_wxs from $regina_wxs.template",
    'mkmsi' => "build an MSI installer from $regina_wxs",
    'cleanwxs' => "clean the generated $regina_wxs",
    'cleanmsi' => "clean the MSI installer and other related generated files",
    'listdlls' => 'list all mingw/qt DLLs that need to ship with Regina',
    'copydlls' => 'copy/replace all mingw/qt DLLs and plugins into the install tree',
    'cleandlls' => 'clean all mingw/qt DLLs and plugins from the install tree',
);

# Automatically deduced configuration variables:
my $msys;
my $mingw;
my $qt;
my $wix;
my $programfiles;
my $wixarch;
my @sys_dll_paths;

my $arch = `uname -m`;
chomp $arch;
if ($arch eq 'x86_64') {
    $msys = 'c:\msys64';
    $mingw = '/mingw64';
    $qt = "/c/Qt/$qtver/mingw${mingwver}_64";
    $wix = "/c/Program Files (x86)/WiX Toolset v$wixver";
    $programfiles = 'ProgramFiles64Folder';
    $wixarch = 'x64';
} elsif ($arch eq 'i686') {
    $msys = 'c:\msys32';
    $mingw = '/mingw32';
    $qt = "/c/Qt/$qtver/mingw${mingwver}_32";
    $wix = "/c/Program Files/WiX Toolset v$wixver";
    $programfiles = 'ProgramFilesFolder';
    $wixarch = 'x86';
} else {
    die "Unknown architecture: $arch";
}
@sys_dll_paths = ("$mingw/bin", "$qt/bin");

-d $mingw or die "ERROR: Missing MinGW: $mingw";
-d $qt or die "ERROR: Missing Qt: $qt";
-d $wix or die "ERROR: Missing WiX: $wix";

sub path_for_mswin {
    my $arg = shift;
    if ($arg =~ /^\/c\//) {
        $arg =~ s/^\/c/c:/;
        $arg =~ tr/\//\\/;
        return $arg;
    } else {
        $arg =~ tr/\//\\/;
        return ($msys . $arg);
    }
}

sub ensure_this_dir {
    (-e 'helper.pl' and -e "$regina_wxs.template") and return;
    print "ERROR: Please run this script from the directory containing it.\n";
    exit 1;
}

sub usage {
    print "Usage: helper.pl <command>\n\n";
    print "Main commands:\n";
    foreach (sort keys %major_commands) {
        print "    $_  :  $major_commands{$_}\n";
    }
    print "\n";
    print "Other commands:\n";
    foreach (sort keys %minor_commands) {
        print "    $_  :  $minor_commands{$_}\n";
    }
    exit 1;
}

$ARGV[0] or &usage;
$ARGV[1] and &usage;

if ($ARGV[0] eq 'dlls') {
    &cleandlls;
    print "\n";
    &copydlls;
} elsif ($ARGV[0] eq 'msi') {
    &mkwxs;
    print "\n";
    &mkmsi;
} elsif ($ARGV[0] eq 'mkwxs') {
    &mkwxs;
} elsif ($ARGV[0] eq 'mkmsi') {
    &mkmsi;
} elsif ($ARGV[0] eq 'cleanwxs') {
    &cleanwxs;
} elsif ($ARGV[0] eq 'cleanmsi') {
    &cleanmsi;
} elsif ($ARGV[0] eq 'listdlls') {
    &listdlls;
} elsif ($ARGV[0] eq 'copydlls') {
    &copydlls;
} elsif ($ARGV[0] eq 'cleandlls') {
    &cleandlls;
} else {
    &usage;
}
exit 0;

# ------------------------------------------------------------------------
# Commands: listdlls / copydlls / cleandlls
# ------------------------------------------------------------------------

sub is_sys_dll {
    my $arg = shift;

    foreach (@sys_dll_paths) {
        -e "$_/$arg" and return "$_/$arg";
    }
    return undef;
}

sub find_dlls {
    my $dll_locs = {};
    my $dll_cases = {};
    my $ignored = {};

    my @executables = glob("$installtree/bin/*.exe");
    foreach (@executables) {
        my $exe_name = `basename $_`;
        chomp $exe_name;

        # print "Analysing $exe_name...\n";

        my $use_path = join(':', @sys_dll_paths);
        open(LDD, "PATH=$use_path /usr/bin/ldd $_ |");
        while (<LDD>) {
            chomp;
            /^\S+\.exe:$/ and next;
            /^\s+(\S+\.dll) => (\S+\.dll) /i or
                die "Cannot interpret ldd output: $_";
            my $dll_name = $1;
            my $dll_loc = $2;

            my $dll_lower = $1;
            $dll_lower =~ tr/A-Z/a-z/;

            # Windows core DLLs do not need to be shipped.
            $dll_loc =~ /^\/c\/windows\/system/i and next;

            my $sys_loc = is_sys_dll($dll_name);
            if (defined $sys_loc) {
                # TODO: Check that $sys_loc matches $dll_loc.

                $dll_locs->{$dll_lower} = $sys_loc;
                $dll_cases->{$dll_lower} = $dll_name;
            } elsif (-e "$installtree/bin/$dll_name") {
                $ignored->{$dll_lower} = "$installtree/bin/$dll_name";
            } else {
                die "Unknown DLL location: $dll_loc";
            }
        }
        close(LDD);
    }

    return [ $dll_locs, $dll_cases, $ignored ];
}

sub listdlls {
    my $results = &find_dlls;
    my $dll_locs = ${$results}[0];
    my $ignored = ${$results}[2];
    foreach (sort values %$dll_locs) {
        print "$_\n";
    }
    if (%$ignored) {
        print "\nIgnored: ";
        print join(', ', sort(keys(%$ignored)));
        print "\n";
    }
}

sub copydlls {
    my $results = &find_dlls;
    my $dll_locs = ${$results}[0];
    my $dll_cases = ${$results}[1];

    foreach (sort keys %$dll_locs) {
        my $src = $dll_locs->{$_};
        my $dest = "$installtree/bin/$dll_cases->{$_}";
        if (-e $dest) {
            print "Replacing: $dll_cases->{$_}  <-  $src\n";
            copy $src, $dest or die;
        } else {
            print "Copying: $dll_cases->{$_}  <-  $src\n";
            copy $src, $dest or die;
        }
    }

    my $pluginDir = "$installtree/bin/plugins";
    if (! -d "$pluginDir") {
        mkdir "$pluginDir" or die;
    }
    foreach (@plugins) {
        my $src = "$qt/plugins/$_";
        my $dest = "$pluginDir/$_";
        if (-e $dest) {
            print "Replacing plugin: $_  <-  $src\n";
            copy $src, $dest or die;
        } else {
            my $destdir = `dirname "$dest"`;
            chomp $destdir;
            if (! -d "$destdir") {
                mkdir $destdir or die;
            }
            print "Copying plugin: $_  <-  $src\n";
            copy $src, $dest or die;
        }
    }
}

sub cleandlls {
    my @dlls = glob("$installtree/bin/*.dll");
    my @burn = ();
    foreach (@dlls) {
        my $dll_name = `basename $_`;
        chomp $dll_name;
        if (is_sys_dll($dll_name)) {
            print "Removing: $dll_name\n";
            push @burn, $_;
        } else {
            print "Keeping: $dll_name\n";
        }
    }
    unlink @burn;

    my $pluginDir = "$installtree/bin/plugins";
    if (-e "$pluginDir") {
        print "Purging plugins: $pluginDir";
        remove_tree($pluginDir, { safe => 1}) or die;
    }
}

# ------------------------------------------------------------------------
# Commands: mkwxs / mkmsi / cleanwxs / cleanmsi
# ------------------------------------------------------------------------

sub cleanwxs {
    &ensure_this_dir;

    if (-e $regina_wxs) {
        print "Removing old $regina_wxs...\n";
        unlink $regina_wxs or die;
    }
}

sub cleanmsi {
    &ensure_this_dir;

    print "Cleaning old WiX output...\n";
    foreach (glob("*.wixobj *.wixpdb *.msi")) {
        print "    $_\n";
        unlink $_ or die;
    }
}

sub mkwxs {
    &ensure_this_dir;

    my $mingw_ms = path_for_mswin($mingw);
    my $qt_ms = path_for_mswin($qt);
    my $srctree_ms = path_for_mswin($srctree);

    my @core_dlls = sort values %{${&find_dlls}[0]};

    &cleanwxs;

    my $cwd = cwd;

    open(TEMPLATE, '<', "$regina_wxs.template") or die;
    open(WXS, '>', $regina_wxs) or die;

    my $line;
    my $partial = '';
    my @path = ();
    my @exclude = ();
    my $currPath = undef;
    my $currExclude = {};
    my ($name, $prefix, $suffix);
    while (<TEMPLATE>) {
        s/\$regina_version/$regina_version/g;
        s/\$regina_build/$regina_build/g;
        s/\$msys/$msys/g;
        s/\$mingw/$mingw_ms/g;
        s/\$qt/$qt_ms/g;
        s/\$programfiles/$programfiles/g;
        s/\$srctree/$srctree_ms/g;

        />.*</ and die;

        if (/^(\s*)\$coredlls\s*$/) {
            print "Identifying core DLLs...\n";
            my $indent = $1;

            my $found_key = 0;
            my $found_py = 0;
            my $path;
            foreach (@core_dlls) {
                # The python library is installed in its own component.
                if (/\/libpython[^\/\\]+\.dll$/) {
                    $found_py and die "Found multiple python DLLs";
                    $found_py = 1;
                    print "    $_  (PythonCore)\n";
                    next;
                }

                $path = path_for_mswin($_);
                if (/\/libstdc\+\+[^\/\\]+\.dll$/) {
                    $found_key and die "Found multiple KeyPath DLLs";
                    $found_key = 1;
                    print "    $_  (KeyPath)\n";
                    print WXS "$indent<File Source='$path'\n";
                    print WXS "$indent KeyPath='yes'/>\n";
                } else {
                    print "    $_\n";
                    print WXS "$indent<File Source='$path'/>\n";
                }
            }
            $found_py or die "Could not find python DLL";
            $found_key or die "Could not find KeyPath DLL";

            next;
        }

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

    chdir $cwd or die;

    print "Created $regina_wxs.\n";
}

sub mkmsi {
    &ensure_this_dir;

    &cleanmsi;

    print "\nBuilding $arch installer for Regina $regina_version...\n\n";

    my $msi = "Regina-$regina_version-$arch.msi";

    system "$wix/bin/candle.exe", '-arch', $wixarch,
        $regina_wxs, 'WixUI_Regina.wxs' and die;

    print "\n";

    system "$wix/bin/light.exe", '-ext', 'WixUIExtension', '-o', $msi,
        'Regina.wixobj', 'WixUI_Regina.wixobj' and die;

    print "\nSUCCESS: $msi\n";
}


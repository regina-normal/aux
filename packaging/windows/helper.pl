#!/usr/bin/perl -w
use strict;
use Archive::Zip;
use File::Basename;
use File::Copy qw(copy);
use File::Path qw(make_path remove_tree);
use Cwd qw(abs_path cwd);

# ------------------------------------------------------------------------
# Begin manual configuration variables
# ------------------------------------------------------------------------
my $installtree_base = 'software'; # actual tree is ~/${installtree_base}-$arch
my $regina_build_suffix = 0;
# ------------------------------------------------------------------------
# End manual configuration variables
# ------------------------------------------------------------------------

# Constants and commands:
my $regina_wxs = 'Regina.wxs';
my @plugins = ( "platforms/qwindows.dll", "styles/qmodernwindowsstyle.dll" );

my %major_commands = (
    'dlls' => 'update DLLs/plugins/etc. in the install tree (cleandlls + copydlls + cleanpython + copypython)',
    'msi' => 'all steps to create a full installer (copypython + mkwxs + mkmsi)',
);

my %minor_commands = (
    'mkwxs' => "build $regina_wxs from $regina_wxs.template",
    'mkmsi' => "build an MSI installer from $regina_wxs",
    'cleanwxs' => "clean the generated $regina_wxs",
    'cleanmsi' => "clean the MSI installer and other related generated files",
    'listdlls' => 'list all mingw/qt DLLs that need to ship with Regina',
    'copydlls' => 'copy/replace all mingw/qt DLLs and plugins into the install tree',
    'cleandlls' => 'clean all mingw/qt DLLs and plugins from the install tree',
    'copypython' => 'copy/replace the python core distribution into the install tree',
    'cleanpython' => 'clean the python core distribution from the install tree',
);

# Configuration variables that are detected later, on demand:
my $srctree;
my $regina_version;

# Configuration variables that are detected automatically, now:
my $archbits;
my $msys;
my $mingw;
my $programfiles;
my $wixarch;
my $installtree;
my $pyver;
my $pyver_short;
my $pyzlib;
my $pyzlibdir;
my $qt;
my $wix;
my @sys_dll_paths;

my $arch = $ENV{MSYSTEM_CARCH};
chomp $arch;
if ($arch eq 'x86_64') {
    $archbits = 64;
    $msys = 'c:\msys64';
    $mingw = '/mingw64';
    $programfiles = 'ProgramFiles64Folder';
    # Assume for now that we are cross-compiling from a 64-bit machine.
    $wixarch = 'x64';
} elsif ($arch eq 'i686') {
    $archbits = 32;
    $msys = 'c:\msys64';
    $mingw = '/mingw32';
    $programfiles = 'ProgramFilesFolder';
    $wixarch = 'x86';
} else {
    die "Unknown architecture: $arch";
}
-d $mingw or die "ERROR: Missing MinGW: $mingw";

# We jump through hoops here because, if we start bash via cmd.exe,
# then HOME will be set to the windows home directory c:\Users\$USER
# and not the MSYS2 home directory /home/$USER .
if ($ENV{USER}) {
    $installtree = "/home/$ENV{USER}/$installtree_base-$arch";
} elsif ($ENV{USERNAME}) {
    $installtree = "/home/$ENV{USERNAME}/$installtree_base-$arch";
} elsif ($ENV{HOME}) {
    $installtree = "$ENV{HOME}/$installtree_base-$arch";
}
if (not defined $installtree) {
    print "ERROR: I could not determine your MSYS2 home directory.\n";
    print "Please set \$HOME accordingly.\n";
    exit 1;
} elsif (not -e "$installtree/bin/regfiledump.exe") {
    print "ERROR: Your install tree does not seem to be set correctly.\n";
    print "The current setting is: $installtree\n";
    print "You can edit this at the top of helper.pl.\n";
    exit 1;
}

$pyver = `python --version`;
$pyver =~ /^Python (\d+\.\d+)\.\d+\s*$/ or die;
$pyver = $1;
$pyver_short = $pyver;
$pyver_short =~ s/\.//;
-d "$mingw/lib/python$pyver" or die "ERROR: Missing Python $pyver";

$pyzlibdir = "$mingw/lib/python$pyver/lib-dynload";
$pyzlib = "zlib-cpython-$pyver_short.dll";
if (! -e "$pyzlibdir/$pyzlib") {
    $pyzlib = "zlib.cp$pyver_short-mingw_$arch.pyd";
    if (! -e "$pyzlibdir/$pyzlib") {
        $pyzlib = "zlib.cp$pyver_short-mingw_${arch}_msvcrt_gnu.pyd";
        -e "$pyzlibdir/$pyzlib" or die "ERROR: Could not find python zlib module";
    }
}

foreach (glob('/c/Qt/*/mingw*')) {
    /^(\/c\/Qt\/\d+\.\d+\.\d+\/mingw\d*_$archbits)\s*$/ or next;
    $qt and die "ERROR: Multiple Qt installations detected";
    $qt = $1;
}
(defined $qt and -d $qt) or die "ERROR: No Qt installation found";

foreach (glob('"/c/Program Files*/WiX Toolset v*"')) {
    /^(\/c\/Program Files.*\/WiX Toolset v[0-9.]+)\s*/ or next;
    $wix and die "ERROR: Multiple WiX installations detected";
    $wix = $1;
}
# Don't complain about a missing WiX unless we are running the command(s)
# that need it.

@sys_dll_paths = ("$mingw/bin", "$qt/bin");

sub path_for_mswin {
    my $arg = shift;
    if ($arg =~ /^\/c\//) {
        $arg =~ s/^\/c/c:/;
        $arg =~ tr/\//\\/;
        return $arg;
    } elsif ($arg =~ /^\/\//) {
        $arg =~ tr/\//\\/;
        return $arg;
    } else {
        $arg =~ tr/\//\\/;
        return ($msys . $arg);
    }
}

sub ensure_paths {
    # Sets $srctree and $regina_version based on the current directory,
    # and then changes into the directory containing helper.pl.

    if (defined $srctree) {
        # We have already done this.
        return;
    }

    # Determine the source tree from the current path.
    if (-e 'CMakeLists.txt' and -e 'engine/regina-core.h') {
        $srctree = abs_path();
    } elsif (-e '../CMakeLists.txt' and -e '../engine/regina-core.h') {
        $srctree = abs_path('..');
    } else {
        print "ERROR: Please run this script from Regina's source tree.";
        exit 1;
    }
    print "Running from source tree: $srctree\n";

    # Detect the Regina version by looking inside the source tree:
    open(CMAKE, '<', "$srctree/CMakeLists.txt") or die;
    while (<CMAKE>) {
        if (/^\s*SET\s*\(PACKAGE_VERSION\s+([0-9.]+)\)\s*$/) {
            $regina_version = $1;
            last;
        }
    }
    close(CMAKE);
    defined $regina_version or die "ERROR: Could not determine Regina version";
    print "Regina version: $regina_version\n";

    # Where does this script live:
    my $helperdir = abs_path(dirname($0));
    print "Windows packaging files: $helperdir\n\n";

    chdir $helperdir or die "Could not chdir to $helperdir";
    (-e 'helper.pl' and -e "$regina_wxs.template") or die;
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
    print "\n";
    &cleanpython;
    print "\n";
    &copypython;
} elsif ($ARGV[0] eq 'msi') {
    &ensure_paths;

    &copypython;
    print "\n";
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
} elsif ($ARGV[0] eq 'copypython') {
    &copypython;
} elsif ($ARGV[0] eq 'cleanpython') {
    &cleanpython;
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
        open(LDD, "PATH=$use_path $mingw/bin/ntldd -R $_ |");
        while (<LDD>) {
            chomp;
            /\.drv => /i and next;

            # ntdll spits out a *lot* of windows internal not-found dlls.
            # We will optimistically assume that everything that *should*
            # be found *can* be found, and any missing DLLs should become
            # apparent at runtime anyway.
            / not found\s*$/ and next;
            /^\s+\S+\.exe => c:\\windows\\system/i and next;

            /^\s+(\S+\.dll) => (\S+\.dll) /i or
                die "Cannot interpret ldd output: $_";
            my $dll_name = $1;
            my $dll_loc = $2;
            $dll_loc =~ s/^C:/\/c/;
            $dll_loc =~ s/\\/\//g;

            my $dll_lower = $dll_name;
            $dll_lower =~ tr/A-Z/a-z/;

            # Windows core DLLs do not need to be shipped.
            $dll_loc =~ /^\/c\/windows\/system/i and next;
            $dll_loc =~ /^\/c\/windows\/syswow64/i and next;
            $dll_loc =~ /^\/c\/windows\/winsxs/i and next;

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
        } else {
            print "Copying: $dll_cases->{$_}  <-  $src\n";
        }
        copy $src, $dest or die;
    }

    my $pluginDir = "$installtree/bin/plugins";
    if (! -d "$pluginDir") {
        make_path "$pluginDir" or die;
    }
    foreach (@plugins) {
        my $src = "$qt/plugins/$_";
        my $dest = "$pluginDir/$_";
        if (-e $dest) {
            print "Replacing plugin: $_  <-  $src\n";
        } else {
            my $destdir = dirname($dest);
            chomp $destdir;
            if (! -d "$destdir") {
                make_path $destdir or die;
            }
            print "Copying plugin: $_  <-  $src\n";
        }
        copy $src, $dest or die;
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
# Commands: copypython / cleanpython
# ------------------------------------------------------------------------

sub copypython {
    my $destDir = "$installtree/lib/regina/python";
    if (! -d "$destDir") {
        make_path "$destDir" or die;
    }

    my $zip = "$destDir/python$pyver_short.zip";
    if (-e $zip) {
        print "Replacing: $zip\n";
    } else {
        print "Copying: $zip\n";
    }
    my $z = Archive::Zip->new();
    $z->addTree("$mingw/lib/python$pyver", '', sub {
        not (/\/distutils(\/|$)/ or /\.py[co]$/);
    });
    $z->writeToFileNamed($zip);

    my $dllSrc = "$pyzlibdir/$pyzlib";
    my $dllDest = "$destDir/$pyzlib";
    if (-e $dllDest) {
        print "Replacing: $pyzlib  <-  $dllSrc\n";
    } else {
        print "Copying: $pyzlib  <-  $dllSrc\n";
    }
    copy $dllSrc, $dllDest or die;
}

sub cleanpython {
    my @zips = glob("$installtree/lib/regina/python/python*.zip");
    my @dlls = glob("$installtree/lib/regina/python/*-cpython-*.dll");

    my @burn = @zips;
    push @burn, @dlls;

    foreach (@burn) {
        my $name = `basename $_`;
        chomp $name;
        print "Removing: $name\n";
    }
    unlink @burn;
}

# ------------------------------------------------------------------------
# Commands: mkwxs / mkmsi / cleanwxs / cleanmsi
# ------------------------------------------------------------------------

sub cleanwxs {
    &ensure_paths;

    if (-e $regina_wxs) {
        print "Removing old $regina_wxs...\n";
        unlink $regina_wxs or die;
    }
}

sub cleanmsi {
    &ensure_paths;

    # If we are cross-compiling, only clean our own arch's installer.
    print "Cleaning old WiX output...\n";
    foreach (glob("*.wixobj *.wixpdb *-$arch.msi")) {
        print "    $_\n";
        unlink $_ or die;
    }
}

sub mkwxs {
    &ensure_paths;

    my $mingw_ms = path_for_mswin($mingw);
    my $qt_ms = path_for_mswin($qt);
    my $srctree_ms = path_for_mswin($srctree);
    my $installtree_ms = path_for_mswin($installtree);
    my $pydir = "$installtree/lib/regina/python";
    my $python_core_ms = path_for_mswin("$pydir/python$pyver_short.zip");
    my $python_zlib_ms = path_for_mswin("$pydir/$pyzlib");

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
        s/\$regina_build/$regina_version.$regina_build_suffix/g;
        s/\$msys/$msys/g;
        s/\$mingw/$mingw_ms/g;
        s/\$qt/$qt_ms/g;
        s/\$programfiles/$programfiles/g;
        s/\$srctree/$srctree_ms/g;
        s/\$installtree/$installtree_ms/g;
        s/\$python_zlib/$python_zlib_ms/g;
        s/\$python_core/$python_core_ms/g;

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
                    print WXS "$indent<File Source=\"$path\" KeyPath=\"yes\" />\n";
                } else {
                    print "    $_\n";
                    print WXS "$indent<File Source=\"$path\" />\n";
                }
            }
            $found_py or die "Could not find python DLL";
            $found_key or die "Could not find KeyPath DLL";

            next;
        } elsif (/^(\s*)\$pythondll\s*$/) {
            print "Identifying python DLL...\n";
            my $indent = $1;

            my $found_py = 0;
            my $path;
            foreach (@core_dlls) {
                /\/libpython[^\/\\]+\.dll$/ or next;

                $found_py and die "Found multiple python DLLs";
                $found_py = 1;

                $path = path_for_mswin($_);
                print "    $_  (KeyPath)\n";
                print WXS "$indent<File Source=\"$path\" KeyPath=\"yes\" />\n";
            }
            $found_py or die "Could not find python DLL";

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

        if ($line =~ /<Directory.*FileSource="([^"]*)"/s) {
            push @path, $currPath;
            push @exclude, $currExclude;
            $currPath = $1;
            $currExclude = {};
            print WXS "$line";
        } elsif ($line =~ /<Directory.*Name="([^"]*)"/s) {
            push @path, $currPath;
            push @exclude, $currExclude;
            $currPath and $currPath .= "\\$1";
            $currExclude = {};
            print WXS "$line";
        } elsif ($line =~ /<\/Directory>/s) {
            $currPath = pop @path;
            $currExclude = pop @exclude;
            print WXS "$line";
        } elsif ($line =~ /<File.*Source="([^"]*)"/s) {
            print WXS "$line";
        } elsif ($line =~ /^(.*<File.*Name=")([^"]*)(".*)$/s) {
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
    (defined $wix and -d $wix) or die "ERROR: No WiX installation found";

    &ensure_paths;

    &cleanmsi;

    print "\nBuilding $arch installer for Regina $regina_version...\n\n";

    my $msi = "Regina-$regina_version-$arch.msi";

    system "$wix/bin/wix.exe", 'extension', 'add', '-g', 'WixToolset.UI.wixext'
        and die;
    system "$wix/bin/wix.exe", 'build', '-arch', $wixarch, '-o', $msi,
        '-ext', 'WixToolset.UI.wixext', $regina_wxs, 'WixUI_Regina.wxs' and die;

    print "\n";

    print "\nSUCCESS: $msi\n";
}


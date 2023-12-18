#!/bin/bash
#
# Regina - Software for low-dimensional topology
# Command-Line Utilities Test Suite
#
# Copyright (c) 2016-2021, Ben Burton
# For further details contact Ben Burton (bab@debian.org).
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# As an exception, when this program is distributed through (i) the
# App Store by Apple Inc.; (ii) the Mac App Store by Apple Inc.; or
# (iii) Google Play by Google Inc., then that store may impose any
# digital rights management, device limits and/or redistribution
# restrictions that are required by its terms of service.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.

set -e
set -o pipefail

# The directory containing the test input files:
testdir=utils/testsuite
if [ ! -e "$testdir"/test.rga ]; then
    echo "ERROR: Test directory "$testdir" does not contain test.rga."
    exit 1
fi

# A suitable output file if one is required:
testout="$AUTOPKGTEST_TMP"/out.rga
if ! touch "$testout"; then
    echo "ERROR: Output file $testout cannot be written to."
    exit 1
fi
if ! rm -f "$testout"; then
    echo "ERROR: Output file $testout cannot be deleted."
    exit 1
fi

# A file that you can neither read from nor write to:
invalidfile=/foo.rga
if [ -e "$testout" ]; then
    echo "ERROR: Invalid file $invalidfile exists."
    exit 1
fi
if touch "$invalidfile" 2>/dev/null; then
    echo "ERROR: Invalid file $testout can be written to."
    exit 1
fi

# A file that exists, but is not a Regina data file:
badfile=utils/testsuite/bad.rga
if [ ! -e "$badfile" ]; then
    echo "ERROR: Bad regina file $badfile does not exist."
    exit 1
fi

function sanitise {
    # When dumping the contents of a Regina data file, this function:
    # - blanks out internal packet IDs (used in script variables), since
    #   these are non-deterministic;
    # - blanks out the regina version that created the file, so that the
    #   test output is stable across different upstream releases.
    sed -e 's#^\tid="[^"]\+"$#\tid="_"#g' \
        -e 's# valueid="[^"]\+"# valueid="_"#g' \
        -e 's#<reginadata engine="[^"]\+">#<reginadata engine="_">#g'
}

function testutil {
    util="$1"
    shift
    echo "============================================================"
    echo "TEST: $util $@" | sed -e "s# /[^ ]\+/out.rga# /tmp/out.rga#g"
    echo "--------------------"
    rm -f "$testout"
    /usr/bin/$util "$@" 2>&1 | sanitise && dummy=
    exitcode=$?
    echo "--------------------"
    echo "Exit code: $exitcode"
    if [ -e "$testout" ]; then
        echo "--------------------"
        raw=`cat "$testout" | shasum`
        uncompressed=`zcat -f "$testout" | shasum`
        if [ "$raw" = "$uncompressed" ]; then
            echo "Output:"
            cat "$testout" | sanitise
        else
            echo "Output (compressed):"
            zcat "$testout" | sanitise
        fi
    fi
}

function donetests {
    echo "============================================================"
}


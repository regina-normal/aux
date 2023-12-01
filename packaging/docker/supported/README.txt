The files in this directory list the versions of each GNU/Linux distribution
that these docker scripts support.  Each file <distro>.list contains the
versions supported on x86_64; for other architectures, we typically support a
subset of this list.  For i386 in particular, this subset is stored in a
separate arch-specific file <distro>-i386.list.

Each *.list is designed to be machine-readable (and in particular, suitable
for use with for loops in bash).

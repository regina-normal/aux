Regina Packaging Directory
--------------------------

This directory tree contains helper files for packaging Regina for
different GNU/Linux distributions and other systems.

Only the package maintainer(s) for Regina should need to use these files.


Subdirectories include:

- debian/ contains packaging for debian-based GNU/Linux distributions,
  such as Debian and Ubuntu.

- rpmspec/ contains packaging for RPM-based GNU/Linux distributions,
  such as Fedora and openSUSE.

- macos/ contains helper tools for distributing macOS app bundles, though
  the app bundles themselves should be built through Xcode.

- windows/ contains helper tools for building Regina on Windows and
  packaging it into a Windows installer.

- checks/ contains some files to copy onto target machines to help test
  that Regina is working correctly.


If you are interested in helping package Regina for other distributions or
platforms, please contact the author at the address below.

 -- Ben Burton <bab@debian.org>, Tue, 19 Jan 2021 09:45:11 +1000

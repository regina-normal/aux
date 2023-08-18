The default Xcode build is fine for development and building ad-hoc
"git snapshot" app bundles.

- To distribute a formal release through the Regina website, apply
  release.diff.  This merely changes the BUILD_INFO setting.

- To distribute a formal release through the Mac App Store, apply
  sandbox.diff (which enables sandboxing and changes BUILD_INFO).
  You may also need to change the ~/Qt/current symlink to point to a
  version of Qt that avoids private API functions forbidden by Apple
  (6.3.2 is fine, 6.4.0 is not).


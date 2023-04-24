The default Xcode build is fine for development.

- To distribute a formal release through the Regina website, apply
  release.diff.  This merely changes the BUILD_INFO setting.

- To distribute a formal release through the Mac App Store, apply
  sandbox.diff (which enables sandboxing and changes BUILD_INFO),
  and for the time being also qt-6.3.2.diff (which downgrades Qt
  to a version that avoids private API functions forbidden by Apple).


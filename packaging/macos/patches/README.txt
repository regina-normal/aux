The default Xcode build uses the system python2 and has no sandboxing.
This is suitable for distribution through the Regina website.

The patches in this directory adjust the Xcode project to build against a
bundled python3, and/or to add sandboxing (as required for distribution
through the App Store).

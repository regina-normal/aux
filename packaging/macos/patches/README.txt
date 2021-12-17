The default Xcode build uses the python3 provided with Xcode, and has no
sandboxing.  This is suitable for distribution through the Regina website.

The patches in this directory adjust the Xcode project to add sandboxing,
as required for distribution through the App Store.

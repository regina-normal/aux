#! /usr/bin/env python3
"""
Creates a nice disk image, with background and /Applications symlink
for the app.

Usage: dmg_maker.py path/to/Regina.app

Thanks to Nathan Dunfield for this original version of this script.
It has been modified since, and so any bugs are most likely mine. - B.B.

One issue here is that Snow Leopard uses a different (undocumented, of
course) format for the .DS_Store files than earlier versions, which makes
disk images created on it not work correctly on those systems.   Thus this "solution" uses a .DS_Store file created on Leopard as follows:

(1) Use Disk Utility to create a r/w DMG large enough to store everything and open it.

(2) Copy over the application and add a symlink to /Applications.

(3) Create a subdirectory ".background" containing the file "background.png".

(4) Open the disk image in the Finder and do View->Hide Tool Bar and then View->Show View Options.  To add the background picture inside the hidden directory, use cmd-shift-g in the file dialog.  Adjust everything to suit, close window and open it.   Then copy the .DS_Store file to dotDS_store.  

"""
import os, sys, re
from math import ceil

name = "Regina"

dist_dir = "dist"

def main():
    # Make sure we are running from the right location.
    if not (os.path.exists('dotDS_Store') and os.path.exists('background.png')):
        print("Please run this script from the directory that contains it.")
        sys.exit(1)

    # Make sure the argument is valid.
    if len(sys.argv) != 2:
        print("Usage: " + sys.argv[0] + " path/to/Regina.app")
        sys.exit(1)
    if not (os.path.exists(sys.argv[1] + "/Contents/MacOS/Regina")):
        print("The argument " + sys.argv[1] + " looks invalid.")
        print("Usage: " + sys.argv[0] + " path/to/Regina.app")
        sys.exit(1)

    # Strip any trailing slash on the argument, which messes up the
    # recursive copy.
    app = sys.argv[1]
    if app[-1:] == '/':
        app = app[:-1]

    # Detect the app version.
    appVersion = ''
    reAppVersion = re.compile('<key>CFBundleShortVersionString</key>\\s+<string>([0-9a-z._-]+)</string>')
    infoFile = app + '/Contents/Info.plist'
    try:
        f = open(infoFile, 'r')
        data = ' '.join(f.readlines())
        f.close()
    except exc:
        print("Could not read info file: " + infoFile)
        sys.exit(1)
    m = reAppVersion.search(data)
    if m:
        appVersion = m.group(1)
    else:
        print("Could not parse info file: " + infoFile)
        sys.exit(1)
    print("Detected Regina version " + appVersion)

    # Detect the custom python version, if any.
    pyType = ''
    rePyVersion = re.compile('^(\\d+)\\.(\\d+)$')
    for fwName in [ 'Python', 'Python3', 'Python2' ]:
        pyVersions = app + '/Contents/Frameworks/' + \
            fwName + '.framework/Versions'
        if os.path.exists(pyVersions):
            # Note: os.scandir() does not exist in python2.
            for i in os.listdir(pyVersions):
                m = rePyVersion.match(i)
                if m:
                    print("Detected Python " + i)
                    pyMajor = m.group(1)
                    pyMinor = m.group(2)
                    pyType = '_py' + str(pyMajor) + str(pyMinor)
                    # The sandboxed bundles strip out the python bin/ folder.
                    if not os.path.exists(pyVersions + '/' + m.group(0) + '/bin'):
                        print("Detected sandboxing")
                        pyType = pyType + '_sandbox'
                    break
            else:
                print('Python framework has unknown version')
                sys.exit(1)
            break

    # Choose sensible names for the final DMGs.
    dmg_real = name + "-" + appVersion + pyType + ".dmg";
    dmg_tmp = name + "-" + appVersion + pyType + "-tmp.dmg";

    # If there is already a sandbox, be a coward and back out.
    if os.path.exists(dist_dir):
        print("There is already a sandbox at " + dist_dir + ".")
        print("Please either delete it or move it out of the way.")
        sys.exit(1)

    # Make sure the dmg isn't currently mounted, or this won't work.  
    mount_name = "/Volumes/" + name
    while os.path.exists(mount_name):
        print("Trying to eject " + mount_name)
        os.system('hdiutil detach "%s"' % mount_name)

    # Remove old dmg if there is one
    while os.path.exists(dmg_real):
        os.remove(dmg_real)
    while os.path.exists(dmg_tmp):
        os.remove(dmg_tmp)

    # Build a new sandbox.
    os.mkdir(dist_dir)
    os.mkdir(dist_dir + '/.background')
    os.symlink("/Applications", dist_dir + "/Applications")
    os.system('cp background.png "%s/.background"' % dist_dir)
    os.system('cp dotDS_Store "%s/.DS_Store"' % dist_dir)
    os.system('cp -a "%s" "%s"' % (app, dist_dir))
    
    # figure out the needed size:
    raw_size = os.popen("du -sh " + dist_dir).read()
    size, units = re.search("([0-9.]+)([KMG])", raw_size).groups()
    new_size = "%d" % ceil(1.2 * float(size)) + units

    # Run the main script:
    print("Building the DMG...")
    dmg_format = 'UDZO' # 'UDRW' if you want to edit the .DS_Store
    os.system('hdiutil create -srcfolder "%s" -volname "%s" -format "%s" "%s"' % (dist_dir, name, dmg_format, dmg_real))
    print("Done.")
              
    
    
if __name__ == "__main__":
    main()




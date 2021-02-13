# Upload the files with /usr/bin/install in a batch.

import os,sys,stat,dputhelper

def upload(fqdn,login,incoming,files_to_upload,debug,compress,progress=0):
        # fqdn, login, compress are ignored
        # Maybe login should be used for "install -o <login>"?

        files_to_fix = []

        incoming = os.path.expanduser(incoming)
        for file in files_to_upload:
                to_fix = os.path.basename(file)
                file_to_fix = os.path.expanduser(os.path.join(incoming, to_fix))
                files_to_fix.append(file_to_fix)
    
        command = ['/usr/bin/install', '-m', '644', incoming]
        command[3:3] = files_to_upload
        if debug:
                print "D: Uploading with cp to %s" % (incoming)
                print "D: %s" % command
        if dputhelper.spawnv(os.P_WAIT, '/usr/bin/install', command):
                print "Error while uploading."
                sys.exit(1)

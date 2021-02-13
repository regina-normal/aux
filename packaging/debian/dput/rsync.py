# Upload the files with rsync via ssh.

import os, sys, dputhelper

def upload(fqdn,login,incoming,files_to_upload,debug, dummy,progress=0):

    files_to_fix = []

    for file in files_to_upload:
        to_fix = os.path.basename(file)
        file_to_fix = os.path.join(incoming, to_fix)
        files_to_fix.append(file_to_fix)

    if login and login != '*':
      login_spec = '%s@'%login
    else:
      login_spec = ''  
    upload_command = ['rsync', '', '--copy-links', '--progress', '--partial',
              '-zave', 'ssh -x', '%s%s:%s' % (login_spec, fqdn, incoming)]
    fix_command = ['ssh', '%s%s' % (login_spec, fqdn), 'chmod', '0644'] \
              + files_to_fix
    upload_command[1:2] = files_to_upload

    if debug:
        print "D: Uploading with rsync to %s%s:%s" % \
            (login_spec, fqdn, incoming)
    if dputhelper.spawnv(os.P_WAIT, '/usr/bin/rsync', upload_command):
        print
        print "Error while uploading."
        sys.exit(1)
    if debug:
        print "D: Fixing file permissions with %s%s" % (login_spec, fqdn)
    if dputhelper.spawnv(os.P_WAIT, '/usr/bin/ssh', fix_command):
        print "Error while fixing permission."
        sys.exit(1)

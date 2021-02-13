# Upload the files with scp in a batch.

import os,sys,stat,dputhelper

def upload(fqdn,login,incoming,files_to_upload,debug,compress,
           ssh_config_options=[],progress=0):

    files_to_fix = []

    for file in files_to_upload:
        to_fix = os.path.basename(file)
        file_to_fix = os.path.join(incoming, to_fix)
        files_to_fix.append(file_to_fix)
    
    command = ['scp', '-p']
    if compress:
        command.append('-C')
    for anopt in ssh_config_options:
        command += ['-o', anopt]
    # TV-Note: Are these / Should these be escaped?
    command += files_to_upload
    if login and login != '*':
        login_spec = '%s@'%login
    else:
        login_spec = ''
    command.append('%s%s:%s' % (login_spec, fqdn, incoming))
    change_mode = 0
    for file in files_to_upload:
        if not stat.S_IMODE(os.lstat(file)[stat.ST_MODE])==0644:
            change_mode = 1
    if debug:
        print "D: Uploading with scp to %s%s:%s" % \
            (login_spec, fqdn, incoming)
        print "D: %s" % command
    if dputhelper.spawnv(os.P_WAIT, '/usr/bin/scp', command):
        print "Error while uploading."
        sys.exit(1)
    if change_mode:
        fix_command = ['ssh']
        for anopt in ssh_config_options:
            fix_command += ['-o', anopt]
        fix_command += ['%s%s' % (login_spec, fqdn), 'chmod', '0644'] \
                         + files_to_fix
        if debug:
            print "D: Fixing some permissions"
            print "D: %s" % fix_command
        if dputhelper.spawnv(os.P_WAIT, '/usr/bin/ssh', fix_command):
            print "Error while fixing permissions."
            sys.exit(1)

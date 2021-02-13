import os, sys, ftplib, getpass, dputhelper

# Upload the files via ftp. (Could need a bit more error-checking.)
def upload(fqdn, login, incoming, files_to_upload, debug, ftp_mode, progress=0, port=21):
    try:
        ftp_connection = ftplib.FTP()
        ftp_connection.connect(fqdn, port)
        if debug:
            print "D: FTP-Connection to host: %s" % fqdn
    except ftplib.all_errors, e:
        print "Connection failed, aborting. Check your network", e
        sys.exit(1)
    prompt = login + "@" + fqdn + " password: "
    if login == 'anonymous':
        password = 'dput@packages.debian.org'
    else:
        password = getpass.getpass(prompt)
    try:
        ftp_connection.login(login,password)
    except ftplib.error_perm:
        print "Wrong Password"
        sys.exit(1)
    except EOFError:
        print "Server closed the connection"
        sys.exit(1)
    ftp_connection.set_pasv(ftp_mode==1)
    try:
        ftp_connection.cwd(incoming)
    except ftplib.error_perm,e:
        if e.args and e.args[0][:3]=='550':
          print "Directory to upload to does not exist."
          sys.exit(1)
        else:
          raise
    if debug:
        print "D: Directory to upload to: %s" % incoming
    for afile in files_to_upload:
        path_to_package, package_name = os.path.split(afile)
        try:
            if debug:
                print "D: Uploading File: %s" % afile
            if progress:
              try:
                size = os.stat(afile).st_size
              except:
                size = -1
                if debug:
                  print "D: Determining size of file '%s' failed"%afile
            f = open(afile,'r')
            if progress:
              f = dputhelper.FileWithProgress(f, ptype=progress,
                                              progressf=sys.stdout,
                                              size=size)
            # print without linefeed
            sys.stdout.write("  Uploading %s: "% package_name)
            sys.stdout.flush()
            ftp_connection.storbinary('STOR ' + package_name, \
                                      f, 1024)
            f.close()
            sys.stdout.write("done.\n")
            sys.stdout.flush()
        except ftplib.all_errors, e:
            print "%s"% (str(e))
            if isinstance(e,ftplib.Error) and e.args and e.args[0][:3]=='553':
              print "Leaving existing %s on the server and continuing" %(package_name)
              print """NOTE: This existing file may have been previously uploaded partially.
       For official Debian upload queues, the dcut(1) utility can be
       used to remove this file, and after an acknowledgement mail is
       received in response to dcut, the upload can be re-initiated."""
              continue
            elif isinstance(e,ftplib.Error) and e.args and e.args[0][:1]=='5':
              print """Note: This error might indicate a problem with your passive_ftp setting.
      Please consult dput.cf(5) for details on this configuration option."""
            if debug:
                print "D: Should exit silently now, but will throw exception for debug."
                raise
            sys.exit(1)
    try:
        ftp_connection.quit()
    except Exception, e:
        if debug:
            print "D: Exception %s while attempting to quit ftp session." % e
            print "D: Throwing an exception for debugging purposes."
            raise

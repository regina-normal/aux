import os, sys, httplib, urllib2, urlparse, getpass, dputhelper
# note: requires >= python 2.4 httplib

# Custom password manager that prompts for a password using getpass() if
# required, and mangles the saved URL so that only one password is prompted for.
class PromptingPasswordMgr(urllib2.HTTPPasswordMgr):
    def __init__(self, username):
        urllib2.HTTPPasswordMgr.__init__(self)
        self.username = username

    def find_user_password(self, realm, authuri):
        # Hack so that we only prompt for a password once
        authuri = self.reduce_uri(authuri)[0]
        authinfo = urllib2.HTTPPasswordMgr.find_user_password(self, realm, authuri)
        if authinfo != (None, None):
            return authinfo

        password = getpass.getpass("    Password for %s:" % realm)
        self.add_password(realm, authuri, self.username, password)
        return (self.username, password)


class AuthHandlerHackAround:
  # fake request and parent object...
  def __init__(self, url, resp_headers, pwman):
    # fake request header dict
    self.headers = {}
    # data
    self.url = url
    self.resp_headers = resp_headers
    self.authhandlers = []
    self.timeout = {}
    # digest untested
    for authhandler_class in [urllib2.HTTPBasicAuthHandler, urllib2.HTTPDigestAuthHandler]:
      ah = authhandler_class(pwman)
      ah.add_parent(self)
      self.authhandlers.append(ah)

  # fake request methods
  def add_header(self, k, v):
    self.headers[k] = v
  def add_unredirected_header(self, k, v):
    self.headers[k] = v
  def get_full_url(self):
    return self.url
  # fake parent method
  def open(self,*args,**keywords):
    pass

  # and what we really want
  def get_auth_headers(self):
    for ah in self.authhandlers:
      try:
        ah.http_error_401(self, None, 401, None, self.resp_headers)
      except ValueError, e:
        pass
      if self.headers:
        return self.headers
    return self.headers
  
# Upload the files via WebDAV
def upload(fqdn, login, incoming, files_to_upload, debug, dummy, progress=0, protocol="http"):
    # EXCEPTION HANDLING!
    if protocol == 'https':
      connclass = httplib.HTTPSConnection
    elif protocol == 'http':
      connclass = httplib.HTTPConnection
    else:
      print >> sys.stderr, "Wrong protocol for upload http[s].py method"
      sys.exit(1)
    if not incoming.startswith('/'):
      incoming = '/'+incoming
    if not incoming.endswith('/'):
      incoming += '/'
    unprocessed_files_to_upload = files_to_upload[:]
    auth_headers = {}
    pwman = PromptingPasswordMgr(login)
    while unprocessed_files_to_upload:
        afile = unprocessed_files_to_upload[0]
        path_to_package, package_name = os.path.split(afile)
        # print without linefeed
        sys.stdout.write("  Uploading %s: "% package_name)
        sys.stdout.flush()
        try:
          size = os.stat(afile).st_size
        except:
          print >> sys.stderr, "Determining size of file '%s' failed"%afile
          sys.exit(1)
        f = open(afile,'r')
        if progress:
          f = dputhelper.FileWithProgress(f, ptype=progress,
                                          progressf=sys.stderr,
                                          size=size)
        url_path = incoming+package_name
        url = "%s://%s%s" % (protocol,fqdn,url_path)
        if debug:
          print "D: HTTP-PUT to URL: %s"%url
        conn = connclass(fqdn)
        conn.putrequest("PUT", url_path, skip_accept_encoding=True)
        # Host: should be automatic
        conn.putheader('User-Agent','dput')
        for k, v in auth_headers.items():
          conn.putheader(k, v)
        conn.putheader('Connection','close')
        conn.putheader('Content-Length',str(size))
        conn.endheaders()
        pos = 0
        while pos < size:
          s = f.read(65536) # sending in 64k steps (screws progress a bit)
          conn.send(s)
          pos += len(s)
        f.close()
        s = ""
        res = conn.getresponse()
        if res.status >= 200 and res.status < 300:
          print "done."
          del unprocessed_files_to_upload[0]
        elif res.status == 401 and not auth_headers:
          print "need authentication."
          auth_headers = AuthHandlerHackAround(url, res.msg, pwman).get_auth_headers()
        else:
          if res.status == 401:
            print "Upload failed as unauthorized: %s"%res.reason
            print "  Maybe wrong username or password?"
          else:
            print "Upload failed: %d %s"% (res.status, res.reason)
          sys.exit(1)
        res.read() # must be done, but we're not interested

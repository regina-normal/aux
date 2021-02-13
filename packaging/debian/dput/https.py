# Bit of a hack, really dput should add /usr/share/dput to the import path.
d = {}
exec open("/usr/share/dput/http.py") in d
real_upload = d["upload"]

def upload(fqdn, login, incoming, files_to_upload, debug, dummy, progress=0):
    return real_upload(fqdn, login, incoming, files_to_upload, debug, dummy, progress, protocol="https")

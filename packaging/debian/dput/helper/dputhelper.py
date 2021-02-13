# wrap spawnv with error output
import os, sys

class DputException(Exception):
  pass
class DputUploadFatalException(DputException):
  pass

def spawnv(mode, file, args):
  ret = os.spawnv(mode,file,args)
  if ret == 127:
    print "Error: Failed to execute '"+file+"'."
    print "       The file may not exist or not be executable."
  elif ret != 0:
    print "Warning: The execution of '"+file+"' as"
    print "  '"+" ".join(args)+"'"
    print "  returned a nonzero exit code."
  return ret

class TimestampFile:
  def __init__(self, f):
    global time
    import time
    self.f = f
    self.buf = ""
  def __getattr__(self, name):
    return getattr(self.f, name)
  def write(self, s):
    self.buf += s
    idx = self.buf.find('\n')
    while idx>=0:
      self.f.write(str(time.time())+': '+self.buf[:idx+1])
      self.buf = self.buf[idx+1:]
      idx = self.buf.find('\n')
      
  def close(self):
    if self.buf:
      self.f.write(str(time.time())+': '+self.buf)
      self.buf = ""
    f.close()
    
class FileWithProgress:
  # FileWithProgress(f, args)
  # mimics a file (passed as f, an open file), but with progress.
  # args: ptype = 1,2 is the type ("|/-\" or numeric), default 0 (no progress)
  #       progressf = file to output progress to (default sys.stdout)
  #       size = size of file (or -1, the default, to ignore)
  #              for numeric output
  #       step = stepsize (default 1024)
  def __init__ (self, f, ptype=0, progressf=sys.stdout, size=-1, step=1024):
    self.f = f
    self.count = 0
    self.lastupdate = 0
    self.ptype = ptype
    self.ppos = 0
    self.progresschars = ['|','/','-','\\']
    self.progressf = progressf
    self.size=size
    self.step=step
    self.closed=0
  def __getattr__(self, name):
    return getattr(self.f, name)
  def read(self, size=-1):
    a = self.f.read(size)
    self.count = self.count + len(a)
    if (self.count-self.lastupdate)>1024:
      if self.ptype == 1:
        self.ppos = (self.ppos+1)%len(self.progresschars)
        self.progressf.write((self.lastupdate!=0)*"\b"+
                             self.progresschars[self.ppos])
        self.progressf.flush()
        self.lastupdate = self.count
      elif self.ptype == 2:
        s = str(self.count/self.step)+"k"
        if self.size >= 0:
          s += '/'+str((self.size+self.step-1)/self.step)+'k'
        s += min(self.ppos-len(s),0)*' '
        self.progressf.write(self.ppos*"\b"+s)
        self.progressf.flush()
        self.ppos = len(s)
    return a
  def close(self):
    if not self.closed:
      self.f.close()
      self.closed = 1
      if self.ptype==1:
        if self.lastupdate:
          self.progressf.write("\b \b")
          self.progressf.flush()
      elif self.ptype==2:
        self.progressf.write(self.ppos*"\b"+self.ppos*" "+self.ppos*"\b")
        self.progressf.flush()
  def __del__(self):
    self.close()

def getopt(args, shortopts, longopts):
  args = args[:]
  optlist = []
  while args and args[0].startswith('-'):
    if args[0] == '--':
      args = args[1:]
      break
    if args[0] == '-':
      break
    if args[0].startswith('--'):
      opt = args.pop(0)[2:]
      if '=' in opt:
        opt, optarg = opt.split('=',1)
      else:
        optarg = None
      prefixmatch = filter(lambda x: x.startswith(opt), longopts)
      if len(prefixmatch) == 0:
        raise DputException('unknown option --%s'%opt)
      elif len(prefixmatch) > 1:
        raise DputException('non-unique prefix --%s'%opt)
      opt = prefixmatch[0]
      if opt.endswith('=='):
        opt = opt[:-2]
        optarg = optarg or ''
      elif opt.endswith('='):
        opt = opt[:-1]
        if not optarg:
          if not args:
            raise DputException('option --%s requires argument'%opt)
          optarg = args.pop(0)
      else:
        if optarg != None:
          raise DputException('option --%s does not take arguments'%opt)
        optarg = ''
      optlist.append(('--'+opt, optarg))
    else:
      s = args.pop(0)[1:]
      while s:
        pos = shortopts.find(s[0])
        if pos == -1:
          raise DputException('option -%s unknown'%s[0])
        if pos+1 >= len(shortopts) or shortopts[pos+1]!=':':
          optlist.append(('-'+s[0],''))
          s = s[1:]
        elif len(s) > 1:
          optlist.append(('-'+s[0],s[1:]))
          s = ''
        elif args:
          optlist.append(('-'+s, args.pop(0)))
          s = ''
        else:
          raise DputException('option -%s requires argument'%s)
  return optlist, args

if __name__ == '__main__':
  import time
  for i in range(1,3):
    sys.stdout.write("Reading dput ")
    sys.stdout.flush()
    a=FileWithProgress(open('/usr/bin/dput'),ptype=i,size=os.stat('/usr/bin/dput').st_size)
    b=' '
    while b:
      b=a.read(4096)
      time.sleep(1)
    a.close()
    print

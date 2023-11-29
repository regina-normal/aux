Keys should be exported without signatures, since rpm's key import cannot
always handle them.  Use:

  gpg --export --export-options export-minimal -a <keyid> ...


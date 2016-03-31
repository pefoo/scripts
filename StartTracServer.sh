# Starts Trac Server

sudo tracd --port 8000 --auth "trac,/var/www/trac/.htpass,MyRealm" --auth "file_diffAndCopyTrac,/var/www/trac/.htpass,MyRealm" /var/www/trac/ /var/www/file_diffAndCopyTrac

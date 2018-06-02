#/usr/bin/perl -w

# Script to get the include path of gcc and output it as path that may be used as environment variable
# Thus the output follows the pattern path1:path2:path3

# This is fun... echo is required to make this gcc call actually quit.
# Since gcc outputs the required information to stderr the redirection from 
# stderr to stdout is made 
$gcc_out=`(echo | gcc -E -v - 2>&1)`;

# Used to grep the include path block. The actual paths are in group named includes
$include_regex=qr/(?s)#include <\.\.\.> search starts here:\s(?<includes>.*)\sEnd/;

if($gcc_out =~ /$include_regex/)
{
	# Get the named match group
	$include_path=$+{includes};
	# Remove spaces
	$include_path =~ s/ //g;
	# Replace newlines with : to satisfy the env variable standards
	$include_path =~ tr{\n}{:};
	print($include_path);
}
else
{
	print("Was not able to get gcc include path from output.");
}



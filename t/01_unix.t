
use lib 'lib';
use Test;
use File::Spec;

plan 1;

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'this is not Unix\'ish'
}
else {
	is File::Spec.curdir, '.', 'curdir is "."';
}

done;

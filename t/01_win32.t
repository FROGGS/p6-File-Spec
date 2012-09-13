
use lib 'lib';
use Test;
use File::Spec;

plan 1;

if $*OS !~~ any(<MSWin32 NetWare symbian>) {
	skip_rest 'this is not Windows\'ish'
}
else {
	is File::Spec.curdir, '.', 'curdir is "."';
}

done;

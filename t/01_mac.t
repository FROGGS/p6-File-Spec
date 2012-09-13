
use lib 'lib';
use Test;
use File::Spec;

plan 1;

if $*OS !~~ 'MacOS' {
	skip_rest 'this is not MacOS'
}
else {
	is File::Spec.curdir, ':', 'curdir is ":"';
}

done;

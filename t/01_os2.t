
use lib 'lib';
use Test;
use File::Spec;

plan 1;

if $*OS !~~ 'os2' {
	skip_rest 'this is not os2'
}
else {
	is File::Spec.curdir, '.', 'curdir is "."';
}

done;

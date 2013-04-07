use v6;
use lib 'lib';
use Test;
use File::Spec;

plan 1;

if $*OS !~~ 'VMS' {
	skip_rest 'this is not VMS'
}
else {
	is File::Spec.curdir, '.', 'curdir is "."';

	is File::Spec.case-tolerant, 1, 'case-tolerant is 0';

}

done;


use Test;
use lib 'lib';
use File::Spec;

plan 20;

eval_lives_ok 'use File::Spec',            'we can use File::Spec';
ok $*OS,                                   "your operating system is $*OS";
_can_ok $_ for <canonpath catdir catfile curdir devnull rootdir tmpdir
                updir no_upwards case_tolerant file_name_is_absolute path
                join splitpath splitdir catpath abs2rel rel2abs>;

sub _can_ok( $method ) {
	ok File::Spec.^methods.grep( $method ), "we can call File::Spec.$method"
}

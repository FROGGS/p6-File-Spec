use v6;
use Test;
use lib 'lib';
use File::Spec;

plan 24;

eval_lives_ok 'use File::Spec', 'we can use File::Spec';
ok $*OS,                        "your operating system is $*OS";
_can_ok $_ for <canonpath catdir catfile curdir devnull rootdir tmpdir
                updir no_upwards case_tolerant file_name_is_absolute path
                join splitpath splitdir catpath abs2rel rel2abs>;

sub _can_ok( $method ) {
	ok File::Spec.^methods.first( $method ), "we can call File::Spec.$method"
}

ok my $foreignOS = ($*OS eq 'MacOS' ?? 'unix' !! 'MacOS'),
	"$foreignOS is not your operating system";
ok my $foreign = File::Spec.new(OS => $foreignOS),
	"we can make $foreignOS File::Spec objects anyway";
ok $foreign.OS_module eq ($*OS eq 'MacOS' ?? 'File::Spec::Unix' !! 'File::Spec::Mac'),
	"correct module {$foreign.OS_module} loaded";
ok $foreign.^methods.first( 'canonpath' ), "we can call methods in {$foreign.OS_module}";

	
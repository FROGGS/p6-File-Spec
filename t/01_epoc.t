use v6;
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Epoc;

plan 8;
my $epoc = File::Spec::Epoc;

say "# File::Spec::Epoc";
my @canonpath = 
	$(''),                                      '',
	$('///../../..//./././a//b/.././c/././'),   '/a/b/../c',
	$('/./'),                                   '/',
	$('/a/./'),                                 '/a';
for @canonpath -> $in, $out {
	is $epoc.canonpath($in), $out, "canonpath: '$in' -> '$out'";
}

is $epoc.curdir,  '.',   'curdir is "."';
is $epoc.updir,   '..',  'updir is ".."';
is $epoc.case-tolerant, True, 'case-tolerant is True';
is $epoc.default-case-tolerant, True, 'default-case-tolerant is True';

done;

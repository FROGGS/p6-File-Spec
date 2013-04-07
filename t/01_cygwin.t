use v6;
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Cygwin;

plan 74;
my $cygwin = File::Spec::Cygwin;

say "# File::Spec::cygwin";
say "# canonpath tests";
my @canonpath =
	'///../../..//./././a//b/.././c/././',   '/a/b/../c',
	'',                       '',
	'a/../../b/c',            'a/../../b/c',
	'/.',                     '/',
	'/./',                    '/',
	'/a/./',                  '/a',
	'/a/.',                   '/a',
	'/../../',                '/',
	'/../..',                 '/';
for @canonpath -> $in, $out {
	is $cygwin.canonpath($in), $out, "canonpath: '$in' -> '$out'";
}

say "# splitdir tests";
my @splitdir =
	'',           '',
	'/d1/d2/d3/', ',d1,d2,d3,',
	'd1/d2/d3/',  'd1,d2,d3,',
	'/d1/d2/d3',  ',d1,d2,d3',
	'd1/d2/d3',   'd1,d2,d3';

for @splitdir -> $in, $out {
	is $cygwin.splitdir(|$in).join(','), $out, "splitdir: '$in' -> '$out'"
}

say "# catdir tests";
is $cygwin.catdir(),                        '', "No argument returns empty string";
my @catdir =
	$( ),                   '',
	$('/'),                  '/',
	$('','d1','d2','d3',''), '/d1/d2/d3',
	$('d1','d2','d3',''),    'd1/d2/d3',
	$('','d1','d2','d3'),    '/d1/d2/d3',
	$('d1','d2','d3'),       'd1/d2/d3',
	$('/','d2/d3'),     '/d2/d3';
for @catdir -> $in, $out {
	is $cygwin.catdir(|$in), $out, "catdir: {$in.perl} -> '$out'";
}

say "# splitpath tests";
my @splitpath = 
	$('file'),            ',,file',
	$('/d1/d2/d3/'),      ',/d1/d2/d3/,',
	$('d1/d2/d3/'),       ',d1/d2/d3/,',
	$('/d1/d2/d3/.'),     ',/d1/d2/d3/.,',
	$('/d1/d2/d3/..'),    ',/d1/d2/d3/..,',
	$('/d1/d2/d3/.file'), ',/d1/d2/d3/,.file',
	$('d1/d2/d3/file'),   ',d1/d2/d3/,file',
	$('/../../d1/'),      ',/../../d1/,',
	$('/././d1/'),        ',/././d1/,';
for @splitpath -> $in, $out {
	is $cygwin.splitpath(|$in).join(','), $out, "splitpath: {$in.perl} -> '$out'"
}

say "# catpath tests";
my @catpath = 
	$('','','file'),            'file',
	$('','/d1/d2/d3/',''),      '/d1/d2/d3/',
	$('','d1/d2/d3/',''),       'd1/d2/d3/',
	$('','/d1/d2/d3/.',''),     '/d1/d2/d3/.',
	$('','/d1/d2/d3/..',''),    '/d1/d2/d3/..',
	$('','/d1/d2/d3/','.file'), '/d1/d2/d3/.file',
	$('','d1/d2/d3/','file'),   'd1/d2/d3/file',
	$('','/../../d1/',''),      '/../../d1/',
	$('','/././d1/',''),        '/././d1/',
	$('d:','d2/d3/',''),        'd:d2/d3/',
	$('d:/','d2','d3/'),        'd:/d2/d3/';
for @catpath -> $in, $out {
	is $cygwin.catpath(|$in), $out, "catpath: {$in.perl} -> '$out'"
}

my @catfile = 
	$('a','b','c'),         'a/b/c',
	$('a','b','./c'),       'a/b/c',
	$('./a','b','c'),       'a/b/c',
	$('c'),                 'c',
	$('./c'),               'c';
for @catfile -> $in, $out {
	is $cygwin.catfile(|$in), $out, "catfile: {$in.perl} -> '$out'"
}


my @abs2rel = 
	$('/t1/t2/t3','/t1/t2/t3'),          '.',
	$('/t1/t2/t4','/t1/t2/t3'),          '../t4',
	$('/t1/t2','/t1/t2/t3'),             '..',
	$('/t1/t2/t3/t4','/t1/t2/t3'),       't4',
	$('/t4/t5/t6','/t1/t2/t3'),          '../../../t4/t5/t6',
#	$('../t4','/t1/t2/t3'),              '../t4',
	$('/','/t1/t2/t3'),                  '../../..',
	$('///','/t1/t2/t3'),                '../../..',
	$('/.','/t1/t2/t3'),                 '../../..',
	$('/./','/t1/t2/t3'),                '../../..',
#	$('../t4','/t1/t2/t3'),              '../t4',
	$('/t1/t2/t3', '/'),                 't1/t2/t3',
	$('/t1/t2/t3', '/t1'),               't2/t3',
	$('t1/t2/t3', 't1'),                 't2/t3',
	$('t1/t2/t3', 't4'),                 '../t1/t2/t3';
for @abs2rel -> $in, $out {
	is $cygwin.abs2rel(|$in), $out, "abs2rel: {$in.perl} -> '$out'"
}

my @rel2abs = 
	$('t4','/t1/t2/t3'),             '/t1/t2/t3/t4',
	$('t4/t5','/t1/t2/t3'),          '/t1/t2/t3/t4/t5',
	$('.','/t1/t2/t3'),              '/t1/t2/t3',
	$('..','/t1/t2/t3'),             '/t1/t2/t3/..',
	$('../t4','/t1/t2/t3'),          '/t1/t2/t3/../t4',
	$('/t1','/t1/t2/t3'),            '/t1',
	$('//t1/t2/t3','/foo'),          '//t1/t2/t3';
for @rel2abs -> $in, $out {
	is $cygwin.rel2abs(|$in), $out, "rel2abs: {$in.perl} -> '$out'"
}


is $cygwin.curdir,  '.',   'curdir is "."';
is $cygwin.devnull, '/dev/null', 'devnull is /dev/null';
is $cygwin.rootdir, '/',  'rootdir is "\\"';
is $cygwin.updir,   '..',  'updir is ".."';
is $cygwin.default-case-tolerant, True, 'default-case-tolerant is True';


if $*OS !~~ any(<cygwin>) {
	skip_rest 'cygwin on-platform tests'
}
else {
	# double check a couple of things to see if File::Spec loaded correctly
	#is File::Spec.devnull, '/dev/null', 'devnull is nul';
	is File::Spec.rootdir, '\\',  'rootdir is "\\"';
	#tmpdir
	#no-upwards
	is File::Spec.case-tolerant, True, 'case-tolerant is True';

	#join

}

done;

use v6;
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Unix;

plan 84;

my $Unix := File::Spec::Unix;

my %canonpath = (
	'///../../..//./././a//b/.././c/././' => '/a/b/../c',
	'a/../../b/c'                         => 'a/../../b/c',
	'/.'                                  => '/',
	'/./'                                 => '/',
	'/a/./'                               => '/a',
	'/a/.'                                => '/a',
	'/../../'                             => '/',
	'/../..'                              => '/',
	'/..'                                 => '/',
);
for %canonpath.kv -> $get, $want {
	is $Unix.canonpath( $get ), $want, "canonpath: '$get' -> '$want'";
}
is $Unix.canonpath(''), '', "canonpath: empty string";

is $Unix.catdir( ),                      '',          "catdir: no arg -> ''";
is $Unix.catdir( '' ),                   '/',         "catdir: '' -> '/'";
is $Unix.catdir( '/' ),                  '/',         "catdir: '/' -> '/'";
is $Unix.catdir( '','d1','d2','d3','' ), '/d1/d2/d3', "catdir: ('','d1','d2','d3','') -> '/d1/d2/d3'";
is $Unix.catdir( 'd1','d2','d3','' ),    'd1/d2/d3',  "catdir: ('d1','d2','d3','') -> 'd1/d2/d3'";
is $Unix.catdir( '','d1','d2','d3' ),    '/d1/d2/d3', "catdir: ('','d1','d2','d3') -> '/d1/d2/d3'";
is $Unix.catdir( 'd1','d2','d3' ),       'd1/d2/d3',  "catdir: ('d1','d2','d3') -> 'd1/d2/d3'";
is $Unix.catdir( '/','d2/d3' ),          '/d2/d3',    "catdir: ('/','d2/d3') -> '/d2/d3'";

is $Unix.catfile('a','b','c'),   'a/b/c', "catfile: ('a','b','c') -> 'a/b/c'";
is $Unix.catfile('a','b','./c'), 'a/b/c', "catfile: ('a','b','./c') -> 'a/b/c'";
is $Unix.catfile('./a','b','c'), 'a/b/c', "catfile: ('./a','b','c') -> 'a/b/c'";
is $Unix.catfile('c'),           'c',     "catfile: 'c' -> 'c'";
is $Unix.catfile('./c'),         'c',     "catfile: './c' -> 'c'";

is $Unix.curdir,  '.',         'curdir is "."';
is $Unix.devnull, '/dev/null', 'devnull is /dev/null';
is $Unix.rootdir, '/',         'rootdir is "/"';

is $Unix.updir,   '..',        'updir is ".."';
my @get  = <. .. .git blib lib t>;
my @want = <.git blib lib t>;
is_deeply $Unix.no_upwards( @get ), @want, 'no_upwards: (. .. .git blib lib t) -> (.git blib lib t)';

ok  $Unix.file_name_is_absolute( '/abcd' ), 'file_name_is_absolute: ok "/abcd"';
nok $Unix.file_name_is_absolute( 'abcd' ),  'file_name_is_absolute: nok "abcd"';

my $path = %*ENV{'PATH'};
%*ENV{'PATH'} = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:';
@want         = </usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games .>;
is_deeply $Unix.path, @want, 'path';
%*ENV{'PATH'} = $path;

is $Unix.join('a','b','c'),   'a/b/c', "join: ('a','b','c') -> 'a/b/c'";
is $Unix.join('a','b','./c'), 'a/b/c', "join: ('a','b','./c') -> 'a/b/c'";
is $Unix.join('./a','b','c'), 'a/b/c', "join: ('./a','b','c') -> 'a/b/c'";
is $Unix.join('c'),           'c',     "join: 'c' -> 'c'";
is $Unix.join('./c'),         'c',     "join: './c' -> 'c'";

my %splitpath = (
	'file'            => ('', '',             'file'),
	'/d1/d2/d3/'      => ('', '/d1/d2/d3/',   ''),
	'd1/d2/d3/'       => ('', 'd1/d2/d3/',    ''),
	'/d1/d2/d3/.'     => ('', '/d1/d2/d3/.',  ''),
	'/d1/d2/d3/..'    => ('', '/d1/d2/d3/..', ''),
	'/d1/d2/d3/.file' => ('', '/d1/d2/d3/',   '.file'),
	'd1/d2/d3/file'   => ('', 'd1/d2/d3/',    'file'),
	'/../../d1/'      => ('', '/../../d1/',   ''),
	'/././d1/'        => ('', '/././d1/',     ''),
);
for %splitpath.kv -> $get, $want {
	is $Unix.splitpath( $get ),
 $want, "splitpath: '$get' -> '$want'";
}

my %splitdir = (
	''           => '',
	'/d1/d2/d3/' => ('', 'd1', 'd2', 'd3', ''),
	'd1/d2/d3/'  => ('d1', 'd2', 'd3', ''),
	'/d1/d2/d3'  => ('', 'd1', 'd2', 'd3'),
	'd1/d2/d3'   => ('d1', 'd2', 'd3'),
);
for %splitdir.kv -> $get, $want {
	is $Unix.splitdir( $get ), $want, "splitdir: '$get' -> '$want'";
}

is $Unix.catpath('','','file'),            'file',            "catpath: ('','','file') -> 'file'";
is $Unix.catpath('','/d1/d2/d3/',''),      '/d1/d2/d3/',      "catpath: ('','/d1/d2/d3/','') -> '/d1/d2/d3/'";
is $Unix.catpath('','d1/d2/d3/',''),       'd1/d2/d3/',       "catpath: ('','d1/d2/d3/','') -> 'd1/d2/d3/'";
is $Unix.catpath('','/d1/d2/d3/.',''),     '/d1/d2/d3/.',     "catpath: ('','/d1/d2/d3/.','') -> '/d1/d2/d3/.'";
is $Unix.catpath('','/d1/d2/d3/..',''),    '/d1/d2/d3/..',    "catpath: ('','/d1/d2/d3/..','') -> '/d1/d2/d3/..'";
is $Unix.catpath('','/d1/d2/d3/','.file'), '/d1/d2/d3/.file', "catpath: ('','/d1/d2/d3/','.file') -> '/d1/d2/d3/.file'";
is $Unix.catpath('','d1/d2/d3/','file'),   'd1/d2/d3/file',   "catpath: ('','d1/d2/d3/','file') -> 'd1/d2/d3/file'";
is $Unix.catpath('','/../../d1/',''),      '/../../d1/',      "catpath: ('','/../../d1/','') -> '/../../d1/'";
is $Unix.catpath('','/././d1/',''),        '/././d1/',        "catpath: ('','/././d1/','') -> '/././d1/'";
is $Unix.catpath('d1','d2/d3/',''),        'd2/d3/',          "catpath: ('d1','d2/d3/','') -> 'd2/d3/'";
is $Unix.catpath('d1','d2','d3/'),         'd2/d3/',          "catpath: ('d1','d2','d3/') -> 'd2/d3/'";

is $Unix.abs2rel('/t1/t2/t3','/t1/t2/t3'),    '.',                  "abs2rel: ('/t1/t2/t3','/t1/t2/t3') -> '.'";
is $Unix.abs2rel('/t1/t2/t4','/t1/t2/t3'),    '../t4',              "abs2rel: ('/t1/t2/t4','/t1/t2/t3') -> '../t4'";
is $Unix.abs2rel('/t1/t2','/t1/t2/t3'),       '..',                 "abs2rel: ('/t1/t2','/t1/t2/t3') -> '..'";
is $Unix.abs2rel('/t1/t2/t3/t4','/t1/t2/t3'), 't4',                 "abs2rel: ('/t1/t2/t3/t4','/t1/t2/t3') -> 't4'";
is $Unix.abs2rel('/t4/t5/t6','/t1/t2/t3'),    '../../../t4/t5/t6',  "abs2rel: ('/t4/t5/t6','/t1/t2/t3') -> '../../../t4/t5/t6'";
#[ "Unix->abs2rel('../t4','/t1/t2/t3'),             '../t4',              "abs2rel: ('../t4','/t1/t2/t3') -> '../t4'";
is $Unix.abs2rel('/','/t1/t2/t3'),            '../../..',           "abs2rel: ('/','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('///','/t1/t2/t3'),          '../../..',           "abs2rel: ('///','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('/.','/t1/t2/t3'),           '../../..',           "abs2rel: ('/.','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('/./','/t1/t2/t3'),          '../../..',           "abs2rel: ('/./','/t1/t2/t3') -> '../../..'";
#[ "Unix->abs2rel('../t4','/t1/t2/t3'),             '../t4',              "abs2rel: ('../t4','/t1/t2/t3') -> '../t4'";
is $Unix.abs2rel('/t1/t2/t3', '/'),           't1/t2/t3',           "abs2rel: ('/t1/t2/t3', '/') -> 't1/t2/t3'";
is $Unix.abs2rel('/t1/t2/t3', '/t1'),         't2/t3',              "abs2rel: ('/t1/t2/t3', '/t1') -> 't2/t3'";
is $Unix.abs2rel('t1/t2/t3', 't1'),           't2/t3',              "abs2rel: ('t1/t2/t3', 't1') -> 't2/t3'";
is $Unix.abs2rel('t1/t2/t3', 't4'),           '../t1/t2/t3',        "abs2rel: ('t1/t2/t3', 't4') -> '../t1/t2/t3'";

is $Unix.rel2abs('t4','/t1/t2/t3'),           '/t1/t2/t3/t4',    "rel2abs: ('t4','/t1/t2/t3') -> '/t1/t2/t3/t4'";
is $Unix.rel2abs('t4/t5','/t1/t2/t3'),        '/t1/t2/t3/t4/t5', "rel2abs: ('t4/t5','/t1/t2/t3') -> '/t1/t2/t3/t4/t5'";
is $Unix.rel2abs('.','/t1/t2/t3'),            '/t1/t2/t3',       "rel2abs: ('.','/t1/t2/t3') -> '/t1/t2/t3'";
is $Unix.rel2abs('..','/t1/t2/t3'),           '/t1/t2/t3/..',    "rel2abs: ('..','/t1/t2/t3') -> '/t1/t2/t3/..'";
is $Unix.rel2abs('../t4','/t1/t2/t3'),        '/t1/t2/t3/../t4', "rel2abs: ('../t4','/t1/t2/t3') -> '/t1/t2/t3/../t4'";
is $Unix.rel2abs('/t1','/t1/t2/t3'),          '/t1',             "rel2abs: ('/t1','/t1/t2/t3') -> '/t1'";

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'Unix on-platform tests'
}
else {
	is File::Spec.MODULE, "File::Spec::Unix", "unix: loads correct module";
	is File::Spec.rel2abs( File::Spec.curdir ), $*CWD, "rel2abs: \$*CWD test";
	ok File::Spec.tmpdir.IO.d && File::Spec.tmpdir.IO.w, "tmpdir: {File::Spec.tmpdir} is a writable directory";
	#case_tolerant
	if (cwd.IO ~~ :w) {
		"casetol.tmp".IO.e or spurt "casetol.tmp", "temporary test file, delete after reading";
		is $Unix.case_tolerant("casetol.tmp"), so "CASETOL.TMP".IO.e, "case_tolerant is {so "CASETOL.TMP".IO.e} in cwd";
		unlink "casetol.tmp";
	}
	else { skip "case_tolerant, no write access in cwd", 1; } 

}

done;

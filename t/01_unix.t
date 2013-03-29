
use lib 'lib';
use Test;
use File::Spec;

plan 81;

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'this is not Unix\'ish'
}
else {
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
		is File::Spec.canonpath( $get ), $want, "canonpath: '$get' -> '$want'";
	}
	is File::Spec.canonpath(''), '', "canonpath: empty string";

	is File::Spec.catdir( ),                      '',          "catdir: no arg -> ''";
	is File::Spec.catdir( '' ),                   '/',         "catdir: '' -> '/'";
	is File::Spec.catdir( '/' ),                  '/',         "catdir: '/' -> '/'";
	is File::Spec.catdir( '','d1','d2','d3','' ), '/d1/d2/d3', "catdir: ('','d1','d2','d3','') -> '/d1/d2/d3'";
	is File::Spec.catdir( 'd1','d2','d3','' ),    'd1/d2/d3',  "catdir: ('d1','d2','d3','') -> 'd1/d2/d3'";
	is File::Spec.catdir( '','d1','d2','d3' ),    '/d1/d2/d3', "catdir: ('','d1','d2','d3') -> '/d1/d2/d3'";
	is File::Spec.catdir( 'd1','d2','d3' ),       'd1/d2/d3',  "catdir: ('d1','d2','d3') -> 'd1/d2/d3'";
	is File::Spec.catdir( '/','d2/d3' ),          '/d2/d3',    "catdir: ('/','d2/d3') -> '/d2/d3'";

	is File::Spec.catfile('a','b','c'),   'a/b/c', "catfile: ('a','b','c') -> 'a/b/c'";
	is File::Spec.catfile('a','b','./c'), 'a/b/c', "catfile: ('a','b','./c') -> 'a/b/c'";
	is File::Spec.catfile('./a','b','c'), 'a/b/c', "catfile: ('./a','b','c') -> 'a/b/c'";
	is File::Spec.catfile('c'),           'c',     "catfile: 'c' -> 'c'";
	is File::Spec.catfile('./c'),         'c',     "catfile: './c' -> 'c'";

	is File::Spec.curdir,  '.',         'curdir is "."';
	is File::Spec.devnull, '/dev/null', 'devnull is /dev/null';
	is File::Spec.rootdir, '/',         'rootdir is "/"';

	#tmpdir

	is File::Spec.updir,   '..',        'updir is ".."';
	my @get  = <. .. .git blib lib t>;
	my @want = <.git blib lib t>;
	is_deeply File::Spec.no_upwards( @get ), @want, 'no_upwards: (. .. .git blib lib t) -> (.git blib lib t)';

	#case_tolerant
	if (cwd.IO ~~ :w) {
		"casetol.tmp".path.e or spurt "casetol.tmp", "temporary test file, delete after reading";
		is File::Spec.case_tolerant("casetol.tmp"), so "CASETOL.TMP".path.e, "case_tolerant is {so "CASETOL.TMP".path.e} in cwd";
		unlink "casetol.tmp";
	}
	else { skip "case_tolerant, no write access in cwd", 1; } 
	
	ok  File::Spec.file_name_is_absolute( '/abcd' ), 'file_name_is_absolute: ok "/abcd"';
	nok File::Spec.file_name_is_absolute( 'abcd' ),  'file_name_is_absolute: nok "abcd"';

	my $path = %*ENV{'PATH'};
	%*ENV{'PATH'} = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:';
	@want         = </usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games .>;
	is_deeply File::Spec.path, @want, 'path';
	%*ENV{'PATH'} = $path;

	is File::Spec.join('a','b','c'),   'a/b/c', "join: ('a','b','c') -> 'a/b/c'";
	is File::Spec.join('a','b','./c'), 'a/b/c', "join: ('a','b','./c') -> 'a/b/c'";
	is File::Spec.join('./a','b','c'), 'a/b/c', "join: ('./a','b','c') -> 'a/b/c'";
	is File::Spec.join('c'),           'c',     "join: 'c' -> 'c'";
	is File::Spec.join('./c'),         'c',     "join: './c' -> 'c'";

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
		is File::Spec.splitpath( $get ), $want, "splitpath: '$get' -> '$want'";
	}

	my %splitdir = (
		''           => '',
		'/d1/d2/d3/' => ('', 'd1', 'd2', 'd3', ''),
		'd1/d2/d3/'  => ('d1', 'd2', 'd3', ''),
		'/d1/d2/d3'  => ('', 'd1', 'd2', 'd3'),
		'd1/d2/d3'   => ('d1', 'd2', 'd3'),
	);
	for %splitdir.kv -> $get, $want {
		is File::Spec.splitdir( $get ), $want, "splitdir: '$get' -> '$want'";
	}

	is File::Spec.catpath('','','file'),            'file',            "catpath: ('','','file') -> 'file'";
	is File::Spec.catpath('','/d1/d2/d3/',''),      '/d1/d2/d3/',      "catpath: ('','/d1/d2/d3/','') -> '/d1/d2/d3/'";
	is File::Spec.catpath('','d1/d2/d3/',''),       'd1/d2/d3/',       "catpath: ('','d1/d2/d3/','') -> 'd1/d2/d3/'";
	is File::Spec.catpath('','/d1/d2/d3/.',''),     '/d1/d2/d3/.',     "catpath: ('','/d1/d2/d3/.','') -> '/d1/d2/d3/.'";
	is File::Spec.catpath('','/d1/d2/d3/..',''),    '/d1/d2/d3/..',    "catpath: ('','/d1/d2/d3/..','') -> '/d1/d2/d3/..'";
	is File::Spec.catpath('','/d1/d2/d3/','.file'), '/d1/d2/d3/.file', "catpath: ('','/d1/d2/d3/','.file') -> '/d1/d2/d3/.file'";
	is File::Spec.catpath('','d1/d2/d3/','file'),   'd1/d2/d3/file',   "catpath: ('','d1/d2/d3/','file') -> 'd1/d2/d3/file'";
	is File::Spec.catpath('','/../../d1/',''),      '/../../d1/',      "catpath: ('','/../../d1/','') -> '/../../d1/'";
	is File::Spec.catpath('','/././d1/',''),        '/././d1/',        "catpath: ('','/././d1/','') -> '/././d1/'";
	is File::Spec.catpath('d1','d2/d3/',''),        'd2/d3/',          "catpath: ('d1','d2/d3/','') -> 'd2/d3/'";
	is File::Spec.catpath('d1','d2','d3/'),         'd2/d3/',          "catpath: ('d1','d2','d3/') -> 'd2/d3/'";

	is File::Spec.abs2rel('/t1/t2/t3','/t1/t2/t3'),    '.',                  "abs2rel: ('/t1/t2/t3','/t1/t2/t3') -> '.'";
	is File::Spec.abs2rel('/t1/t2/t4','/t1/t2/t3'),    '../t4',              "abs2rel: ('/t1/t2/t4','/t1/t2/t3') -> '../t4'";
	is File::Spec.abs2rel('/t1/t2','/t1/t2/t3'),       '..',                 "abs2rel: ('/t1/t2','/t1/t2/t3') -> '..'";
	is File::Spec.abs2rel('/t1/t2/t3/t4','/t1/t2/t3'), 't4',                 "abs2rel: ('/t1/t2/t3/t4','/t1/t2/t3') -> 't4'";
	is File::Spec.abs2rel('/t4/t5/t6','/t1/t2/t3'),    '../../../t4/t5/t6',  "abs2rel: ('/t4/t5/t6','/t1/t2/t3') -> '../../../t4/t5/t6'";
	#[ "Unix->abs2rel('../t4','/t1/t2/t3'),             '../t4',              "abs2rel: ('../t4','/t1/t2/t3') -> '../t4'";
	is File::Spec.abs2rel('/','/t1/t2/t3'),            '../../..',           "abs2rel: ('/','/t1/t2/t3') -> '../../..'";
	is File::Spec.abs2rel('///','/t1/t2/t3'),          '../../..',           "abs2rel: ('///','/t1/t2/t3') -> '../../..'";
	is File::Spec.abs2rel('/.','/t1/t2/t3'),           '../../..',           "abs2rel: ('/.','/t1/t2/t3') -> '../../..'";
	is File::Spec.abs2rel('/./','/t1/t2/t3'),          '../../..',           "abs2rel: ('/./','/t1/t2/t3') -> '../../..'";
	#[ "Unix->abs2rel('../t4','/t1/t2/t3'),             '../t4',              "abs2rel: ('../t4','/t1/t2/t3') -> '../t4'";
	is File::Spec.abs2rel('/t1/t2/t3', '/'),           't1/t2/t3',           "abs2rel: ('/t1/t2/t3', '/') -> 't1/t2/t3'";
	is File::Spec.abs2rel('/t1/t2/t3', '/t1'),         't2/t3',              "abs2rel: ('/t1/t2/t3', '/t1') -> 't2/t3'";
	is File::Spec.abs2rel('t1/t2/t3', 't1'),           't2/t3',              "abs2rel: ('t1/t2/t3', 't1') -> 't2/t3'";
	is File::Spec.abs2rel('t1/t2/t3', 't4'),           '../t1/t2/t3',        "abs2rel: ('t1/t2/t3', 't4') -> '../t1/t2/t3'";

	is File::Spec.rel2abs('t4','/t1/t2/t3'),           '/t1/t2/t3/t4',    "rel2abs: ('t4','/t1/t2/t3') -> '/t1/t2/t3/t4'";
	is File::Spec.rel2abs('t4/t5','/t1/t2/t3'),        '/t1/t2/t3/t4/t5', "rel2abs: ('t4/t5','/t1/t2/t3') -> '/t1/t2/t3/t4/t5'";
	is File::Spec.rel2abs('.','/t1/t2/t3'),            '/t1/t2/t3',       "rel2abs: ('.','/t1/t2/t3') -> '/t1/t2/t3'";
	is File::Spec.rel2abs('..','/t1/t2/t3'),           '/t1/t2/t3/..',    "rel2abs: ('..','/t1/t2/t3') -> '/t1/t2/t3/..'";
	is File::Spec.rel2abs('../t4','/t1/t2/t3'),        '/t1/t2/t3/../t4', "rel2abs: ('../t4','/t1/t2/t3') -> '/t1/t2/t3/../t4'";
	is File::Spec.rel2abs('/t1','/t1/t2/t3'),          '/t1',             "rel2abs: ('/t1','/t1/t2/t3') -> '/t1'";
}

done;

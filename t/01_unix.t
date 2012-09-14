
use lib 'lib';
use Test;
use File::Spec;

plan 32;

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'this is not Unix\'ish'
}
else {
	my %canonpath = (
		'///../../..//./././a//b/.././c/././' => '/a/b/../c',
		''                                    => '',
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

	is File::Spec.case_tolerant, 0, 'case_tolerant is 0';

	ok  File::Spec.file_name_is_absolute( '/abcd' ), 'file_name_is_absolute: ok "/abcd"';
	nok File::Spec.file_name_is_absolute( 'abcd' ),  'file_name_is_absolute: nok "abcd"';

	my $path = %*ENV{'PATH'};
	%*ENV{'PATH'} = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:';
	@want         = </usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games .>;
	is_deeply File::Spec.path, @want, 'path';
	%*ENV{'PATH'} = $path;

	#join
	#splitpath
	#splitdir
	#catpath
	#abs2rel
	#rel2ab
}

done;

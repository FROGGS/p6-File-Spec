
use lib 'lib';
use Test;
use File::Spec;

plan 14;

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'this is not Unix\'ish'
}
else {
	#canonpath
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

	#catdir
	#catfile
	is File::Spec.curdir,  '.',         'curdir is "."';
	is File::Spec.devnull, '/dev/null', 'devnull is /dev/null';
	is File::Spec.rootdir, '/',         'rootdir is "/"';
	#tmpdir
	is File::Spec.updir,   '..',        'updir is ".."';
	#no_upwards
	#case_tolerant
	#file_name_is_absolute
	#path
	#join
	#splitpath
	#splitdir
	#catpath
	#abs2rel
	#rel2ab
}

done;
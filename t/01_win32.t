
use lib 'lib';
use Test;
use File::Spec;

plan 4;

if $*OS !~~ any(<MSWin32 NetWare symbian>) {
	skip_rest 'this is not Windows\'ish'
}
else {
	#canonpath
	#catdir
	#catfile
	is File::Spec.curdir,  '.',   'curdir is "."';
	is File::Spec.devnull, 'nul', 'devnull is /dev/null';
	is File::Spec.rootdir, '\\',  'rootdir is "/"';
	#tmpdir
	is File::Spec.updir,   '..',  'updir is ".."';
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

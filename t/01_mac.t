
use lib 'lib';
use Test;
use File::Spec;

plan 3;

if $*OS !~~ 'MacOS' {
	skip_rest 'this is not MacOS'
}
else {
	#canonpath
	#catdir
	#catfile
	is File::Spec.curdir,  ':',        'curdir is ":"';
	is File::Spec.devnull, 'Dev:Null', 'devnull is /dev/null';
	#rootdir
	#tmpdir
	is File::Spec.updir,   '::',       'updir is "::"';
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

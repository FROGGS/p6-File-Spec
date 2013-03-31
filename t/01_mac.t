use v6;
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Mac;

plan 26; 
my $Mac = File::Spec::Mac.new;
my @splitpath_test = 
	':',              ',:,',
	'::',             ',::,',
	':::',            ',:::,',

	'file',           ',,file',
	':file',          ',:,file',

	['d1', True ],           ',:d1:,', # dir, not volume
	[':d1', True ],          ',:d1:,',
	[':d1', False ],          ',:,d1',
	[':d1:', True ],         ',:d1:,',
	':d1:',           ',:d1:,',
	':d1:d2:d3:',     ',:d1:d2:d3:,',
	[':d1:d2:d3:', True ],   ',:d1:d2:d3:,',
	':d1:file',       ',:d1:,file',
	'::d1:file',      ',::d1:,file',

	['hd:', True ],         'hd:,,',
	'hd:',            'hd:,,',
	'hd:d1:d2:',      'hd:,:d1:d2:,',
	['hd:d1:d2', True ],     'hd:,:d1:d2:,',
	'hd:d1:d2:file',  'hd:,:d1:d2:,file',
	'hd:d1:d2::file', 'hd:,:d1:d2::,file',
	'hd::d1:d2:file', 'hd:,::d1:d2:,file', # invalid path
	'hd:file',        'hd:,,file';

say "# Test splitpath";
for @splitpath_test -> $get, $want { is $Mac.splitpath(|$get).join(','), $want };


if $*OS !~~ 'MacOS' {
	skip_rest 'this is not MacOS'
}
else {
	is File::Spec.canonpath('foo:bar:baz'), 'foo:bar:baz';
	#catdir
	#catfile
	is File::Spec.curdir,  ':',        'curdir is ":"';
	is File::Spec.devnull, 'Dev:Null', 'devnull is /dev/null';
	#rootdir
	#tmpdir
	is File::Spec.updir,   '::',       'updir is "::"';
	#no_upwards

	is File::Spec.case_tolerant, 1, 'case_tolerant is 0';

	#file_name_is_absolute
	#path
	#join
	is File::Spec.splitpath('hd:file'), 'hd:,,file';
	#splitdir
	#catpath
	#abs2rel
	#rel2ab
}

done;

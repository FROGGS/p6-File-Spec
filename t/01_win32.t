
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Win32;

plan 33;
my $win32 = File::Spec::Win32.new;

say "# catdir tests";
is $win32.catdir(),                        '';
is $win32.catdir(''),                      '\\';
is $win32.catdir('/'),                     '\\';
is $win32.catdir('/', '../'),              '\\';
is $win32.catdir('/', '..\\'),             '\\';
is $win32.catdir('\\', '../'),             '\\';
is $win32.catdir('\\', '..\\'),            '\\';
is $win32.catdir('//d1','d2'),             '\\\\d1\\d2';
is $win32.catdir('\\d1\\','d2'),           '\\d1\\d2';
is $win32.catdir('\\d1','d2'),             '\\d1\\d2';
is $win32.catdir('\\d1','\\d2'),           '\\d1\\d2';
is $win32.catdir('\\d1','\\d2\\'),         '\\d1\\d2';
is $win32.catdir('','/d1','d2'),           '\\d1\\d2';
is $win32.catdir('','','/d1','d2'),        '\\d1\\d2';
is $win32.catdir('','//d1','d2'),          '\\d1\\d2';
is $win32.catdir('','','//d1','d2'),       '\\d1\\d2';
is $win32.catdir('','d1','','d2',''),      '\\d1\\d2';
is $win32.catdir('','d1','d2','d3',''),    '\\d1\\d2\\d3';
is $win32.catdir('d1','d2','d3',''),       'd1\\d2\\d3';
is $win32.catdir('','d1','d2','d3'),       '\\d1\\d2\\d3';
is $win32.catdir('d1','d2','d3'),          'd1\\d2\\d3';
is $win32.catdir('A:/d1','d2','d3'),       'A:\\d1\\d2\\d3';
is $win32.catdir('A:/d1','d2','d3',''),    'A:\\d1\\d2\\d3';
is $win32.catdir('A:/d1','B:/d2','d3',''), 'A:\\d1\\B:\\d2\\d3';
is $win32.catdir('A:/'),                   'A:\\';
is $win32.catdir('\\', 'foo'),             '\\foo';
is $win32.catdir('','','..'),              '\\';
is $win32.catdir('A:', 'foo'),             'A:\\foo';

if 0 { #todo
	say "# catpath tests";
	is $win32.catpath('','','file'),                            'file';
	is $win32.catpath('','\\d1/d2\\d3/',''),                    '\\d1/d2\\d3/';
	is $win32.catpath('','d1/d2\\d3/',''),                      'd1/d2\\d3/';
	is $win32.catpath('','\\d1/d2\\d3/.',''),                   '\\d1/d2\\d3/.';
	is $win32.catpath('','\\d1/d2\\d3/..',''),                  '\\d1/d2\\d3/..';
	is $win32.catpath('','\\d1/d2\\d3/','.file'),               '\\d1/d2\\d3/.file';
	is $win32.catpath('','\\d1/d2\\d3/','file'),                '\\d1/d2\\d3/file';
	is $win32.catpath('','d1/d2\\d3/','file'),                  'd1/d2\\d3/file';
	is $win32.catpath('C:','\\d1/d2\\d3/',''),                  'C:\\d1/d2\\d3/';
	is $win32.catpath('C:','d1/d2\\d3/',''),                    'C:d1/d2\\d3/';
	is $win32.catpath('C:','\\d1/d2\\d3/','file'),              'C:\\d1/d2\\d3/file';
	is $win32.catpath('C:','d1/d2\\d3/','file'),                'C:d1/d2\\d3/file';
	is $win32.catpath('C:','\\../d2\\d3/','file'),              'C:\\../d2\\d3/file';
	is $win32.catpath('C:','../d2\\d3/','file'),                'C:../d2\\d3/file';
	is $win32.catpath('','\\../..\\d1/',''),                    '\\../..\\d1/';
	is $win32.catpath('','\\./.\\d1/',''),                      '\\./.\\d1/';
	is $win32.catpath('\\\\node\\share','\\d1/d2\\d3/',''),     '\\\\node\\share\\d1/d2\\d3/';
	is $win32.catpath('\\\\node\\share','\\d1/d2\\d3/','file'), '\\\\node\\share\\d1/d2\\d3/file';
	is $win32.catpath('\\\\node\\share','\\d1/d2\\','file'),    '\\\\node\\share\\d1/d2\\file';
}


if $*OS !~~ any(<MSWin32 NetWare symbian>) {
	skip_rest 'this is not Windows\'ish'
}
else {
	#canonpath
	#catdir
	#catfile
	is File::Spec.curdir,  '.',   'curdir is "."';
	is File::Spec.devnull, 'nul', 'devnull is nul';
	is File::Spec.rootdir, '\\',  'rootdir is "\\"';
	#tmpdir
	is File::Spec.updir,   '..',  'updir is ".."';
	#no_upwards

	is File::Spec.case_tolerant, 1, 'case_tolerant is 1';

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

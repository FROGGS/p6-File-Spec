
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Win32;

plan 121;
my $win32 = File::Spec::Win32.new;

say "#canonpath tests";
is $win32.canonpath(''),               '';
is $win32.canonpath('a:'),             'A:';
is $win32.canonpath('A:f'),            'A:f';
is $win32.canonpath('A:/'),            'A:\\';
is $win32.canonpath('a\\..\\..\\b\\c'), 'a\..\..\b\c';
is $win32.canonpath('//a\\b//c'),      '\\\\a\\b\\c';
is $win32.canonpath('/a/..../c'),      '\\a\\....\\c';
is $win32.canonpath('//a/b\\c'),       '\\\\a\\b\\c';
is $win32.canonpath('////'),           '\\';
is $win32.canonpath('//'),             '\\';
is $win32.canonpath('/.'),             '\\';
is $win32.canonpath('//a/b/../../c'),  '\\\\a\\b\\c';
is $win32.canonpath('\\../temp\\'),    '\\temp';
is $win32.canonpath('\\../'),          '\\';
is $win32.canonpath('\\..\\'),         '\\';
is $win32.canonpath('/../'),           '\\';
is $win32.canonpath('/..\\'),          '\\';
is $win32.canonpath('d1/../foo'),      'd1\\..\\foo';

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
say "# splitpath tests";
is $win32.splitpath('file').join(','),                            ',,file';
is $win32.splitpath('\\d1/d2\\d3/').join(','),                    ',\\d1/d2\\d3/,';
is $win32.splitpath('d1/d2\\d3/').join(','),                      ',d1/d2\\d3/,';
is $win32.splitpath('\\d1/d2\\d3/.').join(','),                   ',\\d1/d2\\d3/.,';
is $win32.splitpath('\\d1/d2\\d3/..').join(','),                  ',\\d1/d2\\d3/..,';
is $win32.splitpath('\\d1/d2\\d3/.file').join(','),               ',\\d1/d2\\d3/,.file';
is $win32.splitpath('\\d1/d2\\d3/file').join(','),                ',\\d1/d2\\d3/,file';
is $win32.splitpath('d1/d2\\d3/file').join(','),                  ',d1/d2\\d3/,file';
is $win32.splitpath('C:\\d1/d2\\d3/').join(','),                  'C:,\\d1/d2\\d3/,';
is $win32.splitpath('C:d1/d2\\d3/').join(','),                    'C:,d1/d2\\d3/,';
is $win32.splitpath('C:\\d1/d2\\d3/file').join(','),              'C:,\\d1/d2\\d3/,file';
is $win32.splitpath('C:d1/d2\\d3/file').join(','),                'C:,d1/d2\\d3/,file';
is $win32.splitpath('C:\\../d2\\d3/file').join(','),              'C:,\\../d2\\d3/,file';
is $win32.splitpath('C:../d2\\d3/file').join(','),                'C:,../d2\\d3/,file';
is $win32.splitpath('\\../..\\d1/').join(','),                    ',\\../..\\d1/,';
is $win32.splitpath('\\./.\\d1/').join(','),                      ',\\./.\\d1/,';
is $win32.splitpath('\\\\node\\share\\d1/d2\\d3/').join(','),     '\\\\node\\share,\\d1/d2\\d3/,';
is $win32.splitpath('\\\\node\\share\\d1/d2\\d3/file').join(','), '\\\\node\\share,\\d1/d2\\d3/,file';
is $win32.splitpath('\\\\node\\share\\d1/d2\\file').join(','),    '\\\\node\\share,\\d1/d2\\,file';
is $win32.splitpath('file',1).join(','),                          ',file,';
is $win32.splitpath('\\d1/d2\\d3/',1).join(','),                  ',\\d1/d2\\d3/,';
is $win32.splitpath('d1/d2\\d3/',1).join(','),                    ',d1/d2\\d3/,';
is $win32.splitpath('\\\\node\\share\\d1/d2\\d3/',1).join(','),   '\\\\node\\share,\\d1/d2\\d3/,';

say "# splitdir tests";
is $win32.splitdir(''),             '';
is $win32.splitdir('\\d1/d2\\d3/').join(','), ',d1,d2,d3,';
is $win32.splitdir('d1/d2\\d3/').join(','),   'd1,d2,d3,';
is $win32.splitdir('\\d1/d2\\d3').join(','),  ',d1,d2,d3';
is $win32.splitdir('d1/d2\\d3').join(','),    'd1,d2,d3';

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
	#rel2abs
	say "# abs2rel tests";
	is $win32.abs2rel('/t1/t2/t3','/t1/t2/t3'),     '.';
	is $win32.abs2rel('/t1/t2/t4','/t1/t2/t3'),     '..\\t4';
	is $win32.abs2rel('/t1/t2','/t1/t2/t3'),        '..';
	is $win32.abs2rel('/t1/t2/t3/t4','/t1/t2/t3'),  't4';
	is $win32.abs2rel('/t4/t5/t6','/t1/t2/t3'),     '..\\..\\..\\t4\\t5\\t6';
	is $win32.abs2rel('../t4','/t1/t2/t3'),         '..\\..\\..\\one\\t4';  # Uses _cwd()
	is $win32.abs2rel('/','/t1/t2/t3'),             '..\\..\\..';
	is $win32.abs2rel('///','/t1/t2/t3'),           '..\\..\\..';
	is $win32.abs2rel('/.','/t1/t2/t3'),            '..\\..\\..';
	is $win32.abs2rel('/./','/t1/t2/t3'),           '..\\..\\..';
	is $win32.abs2rel('\\\\a/t1/t2/t4','/t2/t3'),   '\\\\a\\t1\\t2\\t4';
	is $win32.abs2rel('//a/t1/t2/t4','/t2/t3'),     '\\\\a\\t1\\t2\\t4';
	is $win32.abs2rel('A:/t1/t2/t3','A:/t1/t2/t3'),     '.';
	is $win32.abs2rel('A:/t1/t2/t3/t4','A:/t1/t2/t3'),  't4';
	is $win32.abs2rel('A:/t1/t2/t3','A:/t1/t2/t3/t4'),  '..';
	is $win32.abs2rel('A:/t1/t2/t3','B:/t1/t2/t3'),     'A:\\t1\\t2\\t3';
	is $win32.abs2rel('A:/t1/t2/t3/t4','B:/t1/t2/t3'),  'A:\\t1\\t2\\t3\\t4';
	is $win32.abs2rel('E:/foo/bar/baz'),            'E:\\foo\\bar\\baz';
	is $win32.abs2rel('C:/one/two/three'),          'three';
	is $win32.abs2rel('C:\\Windows\\System32', 'C:\\'),  'Windows\System32';
	is $win32.abs2rel('\\\\computer2\\share3\\foo.txt', '\\\\computer2\\share3'),  'foo.txt';
	is $win32.abs2rel('C:\\one\\two\\t\\asd1\\', 't\\asd\\'), '..\\asd1';
	is $win32.abs2rel('\\one\\two', 'A:\\foo'),     'C:\\one\\two';
}

done;

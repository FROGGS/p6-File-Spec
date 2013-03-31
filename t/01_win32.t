
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Win32;

plan 126;
my $win32 = File::Spec::Win32;

say "# File::Spec::Win32";
say "# canonpath tests";
my @canonpath = 
	'',               '',
	'a:',             'A:',
	'A:f',            'A:f',
	'A:/',            'A:\\',
	'a\\..\\..\\b\\c', 'a\..\..\b\c',
	'//a\\b//c',      '\\\\a\\b\\c',
	'/a/..../c',      '\\a\\....\\c',
	'//a/b\\c',       '\\\\a\\b\\c',
	'////',           '\\',
	'//',             '\\',
	'/.',             '\\',
	'//a/b/../../c',  '\\\\a\\b\\c',
	'\\../temp\\',    '\\temp',
	'\\../',          '\\',
	'\\..\\',         '\\',
	'/../',           '\\',
	'/..\\',          '\\',
	'd1/../foo',      'd1\\..\\foo';
for @canonpath -> $in, $out {
	is $win32.canonpath($in), $out, "canonpath: '$in' -> '$out'";
}

say "# splitdir tests";
my @splitdir = 
	'',              '',
	'\\d1/d2\\d3/',  ',d1,d2,d3,',
	'd1/d2\\d3/',    'd1,d2,d3,',
	'\\d1/d2\\d3',   ',d1,d2,d3',
	'd1/d2\\d3',     'd1,d2,d3';

for @splitdir -> $in, $out {
	is $win32.splitdir(|$in).join(','), $out, "splitdir: '$in' -> '$out'"
}

say "# catdir tests";
is $win32.catdir(),                        '', "No argument returns empty string";
my @catdir = 
	('/').item,                     '\\',
	('/', '../').item,              '\\',
	('/', '..\\').item,             '\\',
	('\\', '../').item,             '\\',
	('\\', '..\\').item,            '\\',
	('//d1','d2').item,             '\\\\d1\\d2',
	('\\d1\\','d2').item,           '\\d1\\d2',
	('\\d1','d2').item,             '\\d1\\d2',
	('\\d1','\\d2').item,           '\\d1\\d2',
	('\\d1','\\d2\\').item,         '\\d1\\d2',
	('','/d1','d2').item,           '\\d1\\d2',
	('','','/d1','d2').item,        '\\d1\\d2',
	('','//d1','d2').item,          '\\d1\\d2',
	('','','//d1','d2').item,       '\\d1\\d2',
	('','d1','','d2','').item,      '\\d1\\d2',
	('','d1','d2','d3','').item,    '\\d1\\d2\\d3',
	('d1','d2','d3','').item,       'd1\\d2\\d3',
	('','d1','d2','d3').item,       '\\d1\\d2\\d3',
	('d1','d2','d3').item,          'd1\\d2\\d3',
	('A:/d1','d2','d3').item,       'A:\\d1\\d2\\d3',
	('A:/d1','d2','d3','').item,    'A:\\d1\\d2\\d3',
	('A:/d1','B:/d2','d3','').item, 'A:\\d1\\B:\\d2\\d3',
	('A:/').item,                   'A:\\',
	('\\', 'foo').item,             '\\foo',
	('','','..').item,              '\\',
	('A:', 'foo').item,             'A:\\foo';
for @catdir -> $in, $out {
	is $win32.catdir(|$in), $out, "catdir: {$in.perl} -> '$out'";
}

say "# splitpath tests";
my @splitpath = 
	'file',                            ',,file',
	'\\d1/d2\\d3/',                    ',\\d1/d2\\d3/,',
	'd1/d2\\d3/',                      ',d1/d2\\d3/,',
	'\\d1/d2\\d3/.',                   ',\\d1/d2\\d3/.,',
	'\\d1/d2\\d3/..',                  ',\\d1/d2\\d3/..,',
	'\\d1/d2\\d3/.file',               ',\\d1/d2\\d3/,.file',
	'\\d1/d2\\d3/file',                ',\\d1/d2\\d3/,file',
	'd1/d2\\d3/file',                  ',d1/d2\\d3/,file',
	'C:\\d1/d2\\d3/',                  'C:,\\d1/d2\\d3/,',
	'C:d1/d2\\d3/',                    'C:,d1/d2\\d3/,',
	'C:\\d1/d2\\d3/file',              'C:,\\d1/d2\\d3/,file',
	'C:d1/d2\\d3/file',                'C:,d1/d2\\d3/,file',
	'C:\\../d2\\d3/file',              'C:,\\../d2\\d3/,file',
	'C:../d2\\d3/file',                'C:,../d2\\d3/,file',
	'\\../..\\d1/',                    ',\\../..\\d1/,',
	'\\./.\\d1/',                      ',\\./.\\d1/,',
	'\\\\node\\share\\d1/d2\\d3/',     '\\\\node\\share,\\d1/d2\\d3/,',
	'\\\\node\\share\\d1/d2\\d3/file', '\\\\node\\share,\\d1/d2\\d3/,file',
	'\\\\node\\share\\d1/d2\\file',    '\\\\node\\share,\\d1/d2\\,file',
	('file',True).item,                ',file,',
	('\\d1/d2\\d3/',1).item,           ',\\d1/d2\\d3/,',
	('d1/d2\\d3/',1).item,             ',d1/d2\\d3/,',
	('\\\\node\\share\\d1/d2\\d3/',1).item,   '\\\\node\\share,\\d1/d2\\d3/,';

for @splitpath -> $in, $out {
	is $win32.splitpath(|$in).join(','), $out, "splitpath: {$in.perl} -> '$out'"
}

say "# catpath tests";
my @catpath = 
	('','','file').item,                            'file',
	('','\\d1/d2\\d3/','').item,                    '\\d1/d2\\d3/',
	('','d1/d2\\d3/','').item,                      'd1/d2\\d3/',
	('','\\d1/d2\\d3/.','').item,                   '\\d1/d2\\d3/.',
	('','\\d1/d2\\d3/..','').item,                  '\\d1/d2\\d3/..',
	('','\\d1/d2\\d3/','.file').item,               '\\d1/d2\\d3/.file',
	('','\\d1/d2\\d3/','file').item,                '\\d1/d2\\d3/file',
	('','d1/d2\\d3/','file').item,                  'd1/d2\\d3/file',
	('C:','\\d1/d2\\d3/','').item,                  'C:\\d1/d2\\d3/',
	('C:','d1/d2\\d3/','').item,                    'C:d1/d2\\d3/',
	('C:','\\d1/d2\\d3/','file').item,              'C:\\d1/d2\\d3/file',
	('C:','d1/d2\\d3/','file').item,                'C:d1/d2\\d3/file',
	('C:','\\../d2\\d3/','file').item,              'C:\\../d2\\d3/file',
	('C:','../d2\\d3/','file').item,                'C:../d2\\d3/file',
	('','\\../..\\d1/','').item,                    '\\../..\\d1/',
	('','\\./.\\d1/','').item,                      '\\./.\\d1/',
	('\\\\node\\share','\\d1/d2\\d3/','').item,     '\\\\node\\share\\d1/d2\\d3/',
	('\\\\node\\share','\\d1/d2\\d3/','file').item, '\\\\node\\share\\d1/d2\\d3/file',
	('\\\\node\\share','\\d1/d2\\','file').item,    '\\\\node\\share\\d1/d2\\file';

for @catpath -> $in, $out {
	is $win32.catpath(|$in), $out, "catpath: {$in.perl} -> '$out'"
}

my @catfile = 
	('a','b','c').item,        'a\\b\\c',
	('a','b','.\\c').item,      'a\\b\\c' ,
	('.\\a','b','c').item,      'a\\b\\c' ,
	('c').item,                'c',
	('.\\c').item,              'c',
	('a/..','../b').item,       '..\\b',
	('A:', 'foo').item,         'A:\\foo';

for @catfile -> $in, $out {
	is $win32.catfile(|$in), $out, "catfile: {$in.perl} -> '$out'"
}


my @abs2rel = 
	('/t1/t2/t3','/t1/t2/t3').item,     '.',
	('/t1/t2/t4','/t1/t2/t3').item,     '..\\t4',
	('/t1/t2','/t1/t2/t3').item,        '..',
	('/t1/t2/t3/t4','/t1/t2/t3').item,  't4',
	('/t4/t5/t6','/t1/t2/t3').item,     '..\\..\\..\\t4\\t5\\t6',
	('/','/t1/t2/t3').item,             '..\\..\\..',
	('///','/t1/t2/t3').item,           '..\\..\\..',
	('/.','/t1/t2/t3').item,            '..\\..\\..',
	('/./','/t1/t2/t3').item,           '..\\..\\..',
	('\\\\a/t1/t2/t4','/t2/t3').item,   '\\\\a\\t1\\t2\\t4',
	('//a/t1/t2/t4','/t2/t3').item,     '\\\\a\\t1\\t2\\t4',
	('A:/t1/t2/t3','A:/t1/t2/t3').item,     '.',
	('A:/t1/t2/t3/t4','A:/t1/t2/t3').item,  't4',
	('A:/t1/t2/t3','A:/t1/t2/t3/t4').item,  '..',
	('A:/t1/t2/t3','B:/t1/t2/t3').item,     'A:\\t1\\t2\\t3',
	('A:/t1/t2/t3/t4','B:/t1/t2/t3').item,  'A:\\t1\\t2\\t3\\t4',
	('E:/foo/bar/baz').item,            'E:\\foo\\bar\\baz',
	#('C:/one/two/three').item,          'three',
	('C:\\Windows\\System32', 'C:\\').item,  'Windows\System32',
	('\\\\computer2\\share3\\foo.txt', '\\\\computer2\\share3').item,  'foo.txt';
	#('../t4','/t1/t2/t3').item,         '..\\..\\..\\one\\t4',  # Uses _cwd()
	#('C:\\one\\two\\t\\asd1\\', 't\\asd\\').item, '..\\asd1',
	#('\\one\\two', 'A:\\foo').item,     'C:\\one\\two';

for @abs2rel -> $in, $out {
	is $win32.abs2rel(|$in), $out, "abs2rel: {$in.perl} -> '$out'"
}



is $win32.curdir,  '.',   'curdir is "."';
is $win32.devnull, 'nul', 'devnull is nul';
is $win32.rootdir, '\\',  'rootdir is "\\"';
is $win32.updir,   '..',  'updir is ".."';
is $win32.default_case_tolerant, True, 'default_case_tolerant is true';


if $*OS !~~ any(<MSWin32 NetWare symbian>) {
	skip_rest 'Win32ish on-platform tests'
}
else {
	# double check a couple of things to see if File::Spec loaded correctly
	is File::Spec.devnull, 'nul', 'devnull is nul';
	is File::Spec.rootdir, '\\',  'rootdir is "\\"';
	#tmpdir
	#no_upwards
	is File::Spec.case_tolerant, 1, 'case_tolerant is 1';

	#file_name_is_absolute
	#join
	#catpath
	#rel2abs

}

done;

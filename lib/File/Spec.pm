
module File::Spec;

use File::Spec::Guts;

my %module = (
	'MacOS'   => 'Mac',
	'MSWin32' => 'Win32',
	'os2'     => 'OS2',
	'VMS'     => 'VMS',
	'epoc'    => 'Epoc',
	'NetWare' => 'Win32', # Yes, File::Spec::Win32 works on NetWare.
	'symbian' => 'Win32', # Yes, File::Spec::Win32 works on symbian.
	'dos'     => 'OS2',   # Yes, File::Spec::OS2 works on DJGPP.
	'cygwin'  => 'Cygwin'
);

sub pck($os) {
	warn $os;
	my $module = "File::Spec::" ~ ($module{$*OS} // 'Unix');

	require $module;

	return ::($module).new;
};

class File::Spec {
	has $!fsg handles File::Spec::Guts = pck($*OS);
#	method canonpath             { ::($module).canonpath()             }
#	method catdir                { ::($module).catdir()                }
#	method catfile               { ::($module).catfile()               }
	method curdir                { $!fsg.curdir()                      }
#	method devnull               { ::($module).devnull()               }
#	method rootdir               { ::($module).rootdir()               }
#	method tmpdir                { ::($module).tmpdir()                }
#	method updir                 { ::($module).updir()                 }
#	method no_upwards            { ::($module).no_upwards()            }
#	method case_tolerant         { ::($module).case_tolerant()         }
#	method file_name_is_absolute { ::($module).file_name_is_absolute() }
#	method path                  { ::($module).path()                  }
#	method join                  { ::($module).join()                  }
#	method splitpath             { ::($module).splitpath()             }
#	method splitdir              { ::($module).splitdir()              }
#	method catpath               { ::($module).catpath()               }
#	method abs2rel               { ::($module).abs2rel()               }
#	method rel2ab                { ::($module).rel2ab()                }
}

1;


module File::Spec::Win32;

my $module = "File::Spec::Unix";
require $module;

class File::Spec::Win32 {
	method canonpath             { ::($module).canonpath()             }
	method catdir                { ::($module).catdir()                }
	method catfile               { ::($module).catfile()               }
	method curdir                { ::($module).curdir()                }
	method devnull               { 'nul'                               }
	method rootdir               { '\\'                                }

	my $tmpdir;
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = self._tmpdir(
			%*ENV{'TMPDIR'},
			%*ENV{'TEMP'},
			%*ENV{'TMP'},
			'SYS:/temp',
			'C:\system\temp',
			'C:/temp',
			'/tmp',
			'/'
		);
	}

	method updir                 { ::($module).updir()                 }
	method no_upwards            { ::($module).no_upwards()            }
	method case_tolerant         { ::($module).case_tolerant()         }
	method file_name_is_absolute { ::($module).file_name_is_absolute() }
	method path                  { ::($module).path()                  }
	method join                  { ::($module).join()                  }
	method splitpath             { ::($module).splitpath()             }
	method splitdir              { ::($module).splitdir()              }
	method catpath               { ::($module).catpath()               }
	method abs2rel               { ::($module).abs2rel()               }
	method rel2abs               { ::($module).rel2abs()               }
}

1;

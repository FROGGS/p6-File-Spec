
module File::Spec::Win32;

my $module = "File::Spec::Unix";
require $module;

class File::Spec::Win32 {
	method canonpath(|c)         { ::($module).canonpath(|c)           }
	method catdir(|c)            { ::($module).catdir(|c)              }
	method catfile(|c)           { ::($module).catfile(|c)             }
	method curdir                { ::($module).curdir()                }
	method devnull               { 'nul'                               }
	method rootdir               { '\\'                                }

	my $tmpdir;
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = ::($module)._tmpdir(
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

	method updir                     { ::($module).updir()                   }
	method no_upwards(|c)            { ::($module).no_upwards(|c)            }
	method case_tolerant             { 1                                     }
	method file_name_is_absolute(|c) { ::($module).file_name_is_absolute(|c) }
	method path                      { ::($module).path()                    }
	method join(|c)                  { ::($module).join()                    }
	method splitpath(|c)             { ::($module).splitpath(|c)             }
	method splitdir(|c)              { ::($module).splitdir(|c)              }
	method catpath(|c)               { ::($module).catpath(|c)               }
	method abs2rel(|c)               { ::($module).abs2rel(|c)               }
	method rel2abs(|c)               { ::($module).rel2abs(|c)               }
}

1;

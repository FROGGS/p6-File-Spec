
module File::Spec::OS2;

my $module = "File::Spec::Unix";
require $module;

class File::Spec::OS2 {
	method canonpath             { ::($module).canonpath()             }
	method catdir                { ::($module).catdir()                }
	method catfile               { ::($module).catfile()               }
	method curdir                { ::($module).curdir()                }
	method devnull               { ::($module).devnull()               }
	method rootdir               { ::($module).rootdir()               }
	method tmpdir                { ::($module).tmpdir()                }
	method updir                 { ::($module).updir()                 }
	method no_upwards            { ::($module).no_upwards()            }
	method case_tolerant         { 1                                   }
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

use v6;
use File::Spec::Unix;
class File::Spec::OS2 is File::Spec::Unix;

my $module = "File::Spec::Unix";
#require $module;

method canonpath             { ::($module).canonpath()             }
method catdir                { ::($module).catdir()                }
method catfile               { ::($module).catfile()               }
method tmpdir                { ::($module).tmpdir()                }
method no_upwards            { ::($module).no_upwards()            }

#method curdir                { ::($module).curdir()                }
#method updir                 { ::($module).updir()                 }
method devnull               { '/dev/nul'                          }
#method rootdir               { ::($module).rootdir()               }
method case_tolerant         { True                                }
method default_case_tolerant { True                                }
method file_name_is_absolute { ::($module).file_name_is_absolute() }
method path                  { ::($module).path()                  }
method join                  { ::($module).join()                  }
method splitpath             { ::($module).splitpath()             }
method splitdir ($dirs)      {  $dirs.split: /<[\\\/]>/            }
method catpath               { ::($module).catpath()               }
method abs2rel               { ::($module).abs2rel()               }
method rel2abs               { ::($module).rel2abs()               }

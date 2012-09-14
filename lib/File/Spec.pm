
module File::Spec;

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

my $module = "File::Spec::" ~ ($module{$*OS} // 'Unix');

require $module;

class File::Spec {
	method canonpath( $path )                   { ::($module).canonpath( $path )                   }
	method catdir( *@parts )                    { ::($module).catdir( @parts )                     }
	method catfile( *@parts )                   { ::($module).catfile( @parts )                    }
	method curdir                               { ::($module).curdir()                             }
	method devnull                              { ::($module).devnull()                            }
	method rootdir                              { ::($module).rootdir()                            }
	method tmpdir                               { ::($module).tmpdir()                             }
	method updir                                { ::($module).updir()                              }
	method no_upwards( *@paths )                { ::($module).no_upwards( @paths )                 }
	method case_tolerant                        { ::($module).case_tolerant()                      }
	method file_name_is_absolute( $file )       { ::($module).file_name_is_absolute( $file )       }
	method path                                 { ::($module).path()                               }
	method join( *@parts )                      { ::($module).join( @parts )                       }
	method splitpath( $path, $no_file = 0 )     { ::($module).splitpath( $path, $no_file )         }
	method splitdir( $path )                    { ::($module).splitdir( $path )                    }
	method catpath( $volume, $directoy, $file ) { ::($module).catpath( $volume, $directoy, $file ) }
	method abs2rel( $path, $base = Str )        { ::($module).abs2rel( $path, $base )              }
	method rel2abs( $path, $base = Str )        { ::($module).rel2abs( $path, $base )              }
}

1;

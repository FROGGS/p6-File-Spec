class File::Spec;
my $module;
my %module = (
	'MacOS'   => 'Mac',
	<MSWin32 os2 dos NetWare symbian> »=>» 'Win32',
	'VMS'     => 'VMS',
	'epoc'    => 'Epoc',
	'cygwin'  => 'Cygwin',
	# in case someone passes a module name instead of an OS string
	#  map it to themselves
	<Unix Mac Win32 Epoc Cygwin> »xx» 2
);

$module = "File::Spec::" ~ (%module{$*OS} // 'Unix');
require $module;

#| MODULE - for module introspection
method MODULE                            { $module; }  # for introspection

#| Returns a copy of the module for the given OS string
#| e.g. File::Spec.os('Win32') returns File::Spec::Win32
method os (Str $OS = $*OS ) {
	$module = "File::Spec::" ~ (%module{$OS} // 'Unix');
	require $module;
	::($module);
}

# class methods
method canonpath( $path )                   { ::($module).canonpath( $path )                   }
method catdir( *@parts )                    { ::($module).catdir( @parts )                     }
method catfile( *@parts )                   { ::($module).catfile( @parts )                    }
method curdir                               { ::($module).curdir()                             }
method devnull                              { ::($module).devnull()                            }
method rootdir                              { ::($module).rootdir()                            }
method tmpdir                               { ::($module).tmpdir()                             }
method updir                                { ::($module).updir()                              }
method no-upwards( *@paths )                { ::($module).no_upwards( @paths )                 }
method default-case-tolerant                { ::($module).default-case-tolerant()              }
method file-name-is-absolute( $file )       { ::($module).file-name-is-absolute( $file )       }
method path                                 { ::($module).path()                               }
method join( *@parts )                      { ::($module).join( @parts )                       }
method splitpath( $path, $no_file = False ) { ::($module).splitpath( $path, $no_file )         }
method splitdir( $path )                    { ::($module).splitdir( $path )                    }
method catpath( $volume, $directory, $file) { ::($module).catpath( $volume, $directory, $file) }
method abs2rel( $path, $base = Str )        { ::($module).abs2rel( $path, $base )              }
method rel2abs( $path, $base = Str )        { ::($module).rel2abs( $path, $base )              }
method case-tolerant( $path = $*CWD )       { ::($module).case-tolerant( $path )               }

method path-components ( $path )            { ::($module).path-components( $path )             }
method join-path ($volume,$directory,$file) { ::($module).join-path($volume, $directory, $file)}


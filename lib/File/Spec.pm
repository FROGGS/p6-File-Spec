class File::Spec;
my $module;
my %module = (
	'MacOS'   => 'Mac',
	<MSWin32 os2 dos NetWare symbian> »=>» 'Win32',
	'VMS'     => 'VMS',
	'cygwin'  => 'Cygwin',
	# in case someone passes a module name instead of an OS string
	#  map it to themselves
	<Unix Mac Win32 Cygwin> »xx» 2
);

$module = "File::Spec::" ~ (%module{$*OS} // 'Unix');
require $module;

#| MODULE - for module introspection
method MODULE                            { $module; }  # for introspection

#| Returns a copy of the module for the given OS string
#| e.g. File::Spec.os('Win32') returns File::Spec::Win32
method os (Str $OS = $*OS ) {
	my $module = "File::Spec::" ~ (%module{$OS} // 'Unix');
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
method no-parent-or-current-test            { ::($module).no-parent-or-current-test            }
method file-name-is-absolute( $file )       { ::($module).file-name-is-absolute( $file )       }
method path                                 { ::($module).path()                               }
method splitpath( $path, $no_file = False ) { ::($module).splitpath( $path, $no_file )         }
method splitdir( $path )                    { ::($module).splitdir( $path )                    }
method catpath( $volume, $directory, $file) { ::($module).catpath( $volume, $directory, $file) }
method abs2rel( |c )                        { ::($module).abs2rel( |c )                        }
method rel2abs( |c )                        { ::($module).rel2abs( |c )                        }

method split ( $path )                       { ::($module).split( $path )                      }
method join ( $volume, $directory, $file )   { ::($module).join( $volume, $directory, $file )  }


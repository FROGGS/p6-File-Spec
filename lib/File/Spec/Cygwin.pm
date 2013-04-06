use File::Spec::Unix;
use File::Spec::Win32;
class File::Spec::Cygwin is File::Spec::Unix;

#| Any C<\> (backslashes) are converted to C</> (forward slashes),
#| and then File::Spec::Unix.canonpath() is called on the result.
method canonpath (Mu:D $path as Str is copy) {
	$path ~~ s:g★\\★/★;   #::

	# Handle network path names beginning with double slash
	my $node = '';
	if $path ~~ s★^ ('//' <-[/]>+) [ '/' | $ ]  ★/★ {
	$node = ~$0;
	}
	$node ~ File::Spec::Unix.canonpath($path);
}

#| Calls the Unix version, and additionally prevents
#| accidentally creating a //network/path.
method catdir ( *@paths ) {
	# return unless @_;

	my $result = File::Spec::Unix.catdir(@paths);

	# Don't create something that looks like a //network/path
	$result.subst(/ <[\\\/]> ** 2..*/, '/'); 	#/

	# I think this P5 would probably still be wrong if ('', '/', 'foo') was passed :-\
	#if (@paths[0] and (@paths[0] eq '/' or @paths[0] eq '\\')) {
	#    shift;
	#    return $self->SUPER::catdir('', @_);
	#}
	#$self->SUPER::catdir(@_);
}


#| True is returned if the file name begins with C<drive_letter:/>,
#| and if not, File::Spec::Unix.file_name_is_absolute is called.
sub file_name_is_absolute ($file) {
    return True if $file ~~ m★ ^ [<[A..Z a..z]>:]?  <[\\/]>★; # C:/test
    File::Spec::Unix.file_name_is_absolute($file);
}

method tmpdir {
    state $tmpdir;
    return $tmpdir if defined $tmpdir;
    $tmpdir = File::Spec::Unix._tmpdir(
		 %*ENV<TMPDIR>,
		 "/tmp",
		 %*ENV<TMP>,
		 %*ENV<TEMP>,
		 'C:/temp',
		 self.curdir );
}


#| Paths might have a volume, so we use Win32 splitpath and catpath instead
method splitpath ( $path, $nofile = False )      { File::Spec::Win32.splitpath( $path, $nofile ) }
method catpath (|c)           { File::Spec::Win32.catpath(|c).subst(:global, '\\', '/') }
method path-components($path) { File::Spec::Win32.path-components($path) }
method join-path (|c)         { self.catpath(|c)                    }

#method catfile               { ::($module).catfile()               }
#method curdir                { ::($module).curdir()                }
#method devnull               { ::($module).devnull()               }
#method rootdir               { ::($module).rootdir()               }
#method updir                 { ::($module).updir()                 }
#method no_upwards            { ::($module).no_upwards()            }
#method case_tolerant         { ::($module).case_tolerant()         }
method default_case_tolerant { True                                }
#method path                  { ::($module).path()                  }
#method join                  { ::($module).join()                  }
#method splitpath             { ::($module).splitpath()             }
#method splitdir              { ::($module).splitdir()              }
#method catpath               { ::($module).catpath()               }
#method abs2rel               { ::($module).abs2rel()               }
#method rel2abs               { ::($module).rel2abs()               }
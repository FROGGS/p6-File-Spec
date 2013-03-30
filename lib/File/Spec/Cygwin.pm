use File::Spec::Unix;
class File::Spec::Cygwin is File::Spec::Unix;

my $module = "File::Spec::Unix";
require $module;

#| Any C<\> (backslashes) are converted to C</> (forward slashes),
#| and then File::Spec::Unix.canonpath() is called on the result.
method canonpath (Mu:D $path as Str is copy) {
	$path ~~ s:g★\\★/★;

	# Handle network path names beginning with double slash
	my $node = '';
	if $path ~~ s★^ ('//' <-[/]>+) [ '/' | $ ]  ★/★ {
	$node = ~$0;
	}
	$node ~ ::($module).canonpath($path);
}

#| Calls the Unix version, and additionally prevents
#| accidentally creating a //network/path.
method catdir ( *@paths ) {
	# return unless @_;

	my $result = ::($module).catdir(@paths);

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
    ::($module).file_name_is_absolute($file);
}

method tmpdir {
    state $tmpdir;
    return $tmpdir if defined $tmpdir;
    $tmpdir = ::($module)._tmpdir(
		 %*ENV<TMPDIR>,
		 "/tmp",
		 %*ENV<TMP>,
		 %*ENV<TEMP>,
		 'C:/temp',
		 self.curdir );
}

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
say "end";
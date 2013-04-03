use File::Spec::Unix;
class File::Spec::VMS is File::Spec::Unix;

my $module = "File::Spec::Unix";
#require $module;
my $unix_report = _unix_rpt;

sub _unix_rpt {
	# VMS::Feature is supposedly the "preferred" way of looking this up
	# but I can't even find the module on CPAN.
	#if $use_feature {
	#    VMS::Feature::current("filename_unix_report");
	#} else {
	my $env_unix_rpt = %*ENV{'DECC$FILENAME_UNIX_REPORT'} || '';
	so $env_unix_rpt ~~ m:i/^[ET1]/;  #:
}

method path {
	my (@dirs,$dir,$i);
	$i = 0;
	while $dir = %*ENV{'DCL$PATH;' ~ $i++} { push(@dirs,$dir) }
	return @dirs;
}

method file_name_is_absolute ($file) {
    # If it's a logical name, expand it.
    $file = %*ENV{$file} while $file ~~ /^ <+alnum +[_$-]>+ $/ && %*ENV{$file};
    so $file ~~ /^ '/'       
		| [ '<' | '[' ]  <-[ \.\-\]\> ]> 
		| ':' <-[\<\[]> /;          #'
}

method tmpdir {
	state $tmpdir;
	return $tmpdir if defined $tmpdir;
	$tmpdir = $unix_report
	            ?? self._tmpdir('/tmp', '/sys$scratch', %*ENV<TMPDIR>)
	            !! self._tmpdir( 'sys$scratch:', %*ENV<TMPDIR> );
}

method canonpath             { ::($module).canonpath()             }
method catdir                { ::($module).catdir()                }
method catfile               { ::($module).catfile()               }
method curdir                { $unix_report ?? '.' !! '[]'         }
method devnull               { $unix_report ?? '/dev/null' !! "_NLA0:" }
method rootdir               { ::($module).rootdir()               }
method updir                 { $unix_report ?? '..' !! '[-]'       }
method no_upwards            { ::($module).no_upwards()            }
method case_tolerant         { True                                }
method default_case_tolerant { True                                }
method join                  { ::($module).join()                  }
method splitpath             { ::($module).splitpath()             }
method splitdir              { ::($module).splitdir()              }
method catpath               { ::($module).catpath()               }
method abs2rel               { ::($module).abs2rel()               }
method rel2abs               { ::($module).rel2abs()               }

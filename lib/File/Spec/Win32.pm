
class File::Spec::Win32 {
	my $module = "File::Spec::Unix";
	require $module;

	# Some regexes we use for path splitting
	my $driveletter = regex { <[a..zA..Z]> ':' }
	my $slash	= regex { '/' | '\\' }
	my $UNCpath     = regex { [<$slash> ** 2] <-[\\\/]>+  <$slash>  <-[\\\/]>+  }
	my $volume      = regex { $<driveletter>=<$driveletter> | $<UNCpath>=<$UNCpath> }


	method canonpath(|c)         { ::($module).canonpath(|c)           }

	method catdir(*@dirs)            {
		# Legacy / compatibility support
		return "" unless @dirs;
		return canon_cat( "\\", |@dirs )
			if @dirs[0] eq "";

		# Compatibility with File::Spec <= 3.26:
		#     catdir('A:', 'foo') should return 'A:\foo'.
		if @dirs[0] ~~ /^<$driveletter>$/ {
		#	say @dirs.perl;
			return canon_cat( (@dirs[0]~'\\'), |@dirs[1..*] )
		}
		#	say @dirs.perl;
		return canon_cat(|@dirs);
	}

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
	method file_name_is_absolute ($path) {
		# As of right now, this returns 2 if the path is absolute with a
		# volume, 1 if it's absolute with no volume, 0 otherwise.
		given $path {
			when /^ [<$driveletter> <$slash> | <$UNCpath>]/ { 2 }
			when /^ <$slash> /                              { 1 }
			default 					{ 0 }
		} #/
	}
	method path                      { ::($module).path()                    }
	method join(|c)                  { ::($module).join()                    }
	method splitpath(|c)             { ::($module).splitpath(|c)             }
	method splitdir(|c)              { ::($module).splitdir(|c)              }
	method catpath(|c)               { ::($module).catpath(|c)               }
	method abs2rel(|c)               { ::($module).abs2rel(|c)               }
	method rel2abs(|c)               { ::($module).rel2abs(|c)               }

	sub canon_cat ( $first is copy, *@rest ) {

		my $volumematch =
		     $first ~~ /^ ([   <$driveletter> <$slash>?
				    | <$UNCpath>
				    | <$slash>+ ])?
				   (.*)
				/;
		my $volume = ~$volumematch[0];
		$first =     ~$volumematch[1];
		$volume ~~ s:g/ '/' /\\/;     #::
	
		my $path = join "\\", $first, @rest.flat;

		$path ~~ s:g/ <$slash>+ /\\/;    #:: xx/yy --> xx\yy & xx\\yy --> xx\yy

		$path ~~ s:g/[ ^ | '\\']   '.'  '\\.'*  [ '\\' | $ ]/\\/;  #:: xx/././yy --> xx/yy

		if $*OS ne "Win32" {
			#netware or symbian ... -> ../..
			#unknown if .... or higher is supported
			$path ~~ s:g/ <?after ^ | '\\'> '...' <?before '\\' | $ > /..\\../; #::
		}

		#Perl 5 File::Spec does " xx\yy\..\zz --> xx\zz" here, but Win >= Vista
		# does symlinks linux style, so we're taking that out.

		$path ~~ s/^ '\\' //;		# \xx --> xx  NOTE: this is *not* root
		$path ~~ s/ '\\' $//;		# xx\ --> xx


		if ( $volume ~~ / '\\' $ / ) {
							# <vol>\.. --> <vol>\ 
			$path ~~ s/ ^			# at begin
				    '..'
				    '\\..'*		# and more
				    [ '\\' | $ ]	# at end or followed by slash
				 //;
		}

		if $path eq '' {		# \\HOST\SHARE\ --> \\HOST\SHARE
			$volume ~~ s/<?before '\\\\' .*> '\\' $ //;
			return $volume;
		}

		return $path ne "" || $volume ?? $volume ~ $path !! ".";
	}

}

#my $foo = File::Spec::Win32.new;
#say $foo.file_name_is_absolute("C:\\doc & shit\\moo.exe");
#say $foo.catdir('C:\\', "perl", "../erf", "lolx\\\\e");


class File::Spec::Mac;

#This module is for Mac OS Classic.  Mac OS X (darwin) uses File::Spec::Unix.

my $module = "File::Spec::Unix";
require $module;

method canonpath ($path)     { $path                               }
method catdir                { ::($module).catdir()                }
method catfile               { ::($module).catfile()               }
method curdir                { ':'                                 }
method devnull               { 'Dev:Null'                          }
method rootdir               { ::($module).rootdir()               }

my $tmpdir;
method tmpdir {
	return $tmpdir if $tmpdir.defined;
	$tmpdir = self._firsttmpdir( %*ENV{'TMPDIR'} );
}

method updir                 { '::'                                }
method no-parent-or-current-test  { ::($module).no-parent-or-current-test }
method case-tolerant         { 1                                   }
method file-name-is-absolute ($path) {
	do given $path {
		when  m/':'/	{ ! ($path ~~ /^':'/) }
		when ''		{ True  }
		default		{ False }	#i.e. paths like "foo"
	}
}
method path                  { ::($module).path()                  }
method join                  { ::($module).join()                  }
method split ($path)         { self.splitpath($path)               }
  #double-check this, not sure splitpath produces correct result

method splitpath ($path as Str, $nofile as Bool = False) {
	my ($volume,$directory,$file, $match);

	if $nofile {
		$match = $path ~~
		    m/^ $<volume>=[ <-[:]>+ ':']?
			$<dir>=[ .* ]
			$<file> = [ ]/;
	}
	else {
		$match = $path ~~
		    m/^ $<volume>=[ <-[:]>+ ':']?
			$<dir>=[ .* ':' ]?
			$<file>=[ .* ]/;
	}
	$volume    = ~$match<volume>;
	$directory = ~$match<dir>;
	$file      = ~$match<file>;

	$directory = ":$directory" if $volume && $directory; # take care of "HD::dir"
	if ($directory) {
		# Make sure non-empty directories begin and end in ':'
		$directory ~= ':' unless (substr($directory,*-1) eq ':');
		$directory = ":$directory" unless (substr($directory,0,1) eq ':');
	}

	return ( $volume, $directory, $file );
}


method splitdir              { ::($module).splitdir()              }
method catpath               { ::($module).catpath()               }
method abs2rel               { ::($module).abs2rel()               }
method rel2abs               { ::($module).rel2abs()               }


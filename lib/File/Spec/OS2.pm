use v6;
use File::Spec::Win32;
class File::Spec::OS2 is File::Spec::Win32;

# Some regexes we use for path splitting
my $driveletter = regex { <[a..z A..Z]> ':' }
my $slash	= regex { '/' | '\\' }

method devnull               { '/dev/nul'                          }
method case_tolerant         { True                                }
method default_case_tolerant { True                                }

method file_name_is_absolute ($file) { so $file ~~ /^ <$driveletter>? <$slash>/ }

method path {
	%*ENV<PATH>\
		.subst(:global, '\\', '/')\
		.split(';')\
		.map: { $_ eq '' ?? '.' !! $_ };
}


method tmpdir {
	state $tmpdir;
	return $tmpdir if $tmpdir.defined;
	return $tmpdir = self._tmpdir(
				|%*ENV<TMPDIR TEMP TMP>,
				|< /tmp / >,
				self.curdir
	                 );
}

method catdir (*@dirs) {
	my $path = @dirs\
		.subst(:global, '\\', '/')\
		.map( { $_ ~~ m❚'/' $❚ ?? $_ ~ '/' !! $_ } )\
		.join;
	self.canonpath($path);
}

sub canonpath ($path) {
	return unless defined $path;

	$path ~~ s/^<[a..z]>:/{ uc $() }/;
	$path ~~ s:g❚\\❚/❚; #::
	#$path =~ s| ([^/])/+ |$1/|g;                  # xx////xx  -> xx/xx
	#$path ~~ s:g❚'/'** 2..*❚/❚;       #::  # xx////xx  -> xx/xx
	#$path ~~ s:g❚'/.'+ '/'❚/❚;     #::              # xx/././xx -> xx/xx
	$path ~~ s:g❚'/' ['.'? '/']+ ❚/❚;   #::   # xx///xx/././xx  -> xx/xx/xx
	$path ~~ s❚^ './'+ <?before <-[/]>>❚❚;		# ./xx      -> xx
	$path ~~ s❚'/' $❚❚
		unless $path ~~ m❚^ <$driveletter>? '/' $❚; # xx/       -> xx
	$path ~~ s❚^ '/..' $❚/❚;                     # /..    -> /
	$path ~~ s❚^ '/..'+ ❚❚;               # /../xx -> /xx
	return $path;
}





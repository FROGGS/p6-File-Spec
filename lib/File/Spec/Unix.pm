
module File::Spec::Unix;

class File::Spec::Unix {
	method canonpath( $path is copy ) {
		return unless $path.defined;

		# Handle POSIX-style node names beginning with double slash (qnx, nto)
		# (POSIX says: "a pathname that begins with two successive slashes
		# may be interpreted in an implementation-defined manner, although
		# more than two leading slashes shall be treated as a single slash.")
		my $node = '';
		my $double_slashes_special = $*OS eq 'qnx' || $*OS eq 'nto';


		if $double_slashes_special
		&& ( $path ~~ s[^(\/\/<-[\/]>+)\/?$] = '' || $path ~~ s[^(\/\/<-[\/]>+)\/] = '/' ) {
			$node = $0;
		}

		$path ~~ s:g[\/+]            = '/';                     # xx////xx  -> xx/xx
		$path ~~ s:g[[\/\.]+[\/|$]] = '/';                     # xx/././xx -> xx/xx
		$path ~~ s[^[\.\/]+]         = '' unless $path eq "./"; # ./xx      -> xx
		$path ~~ s[^\/[\.\.\/]+]     = '/';                     # /../../xx -> xx
		$path ~~ s[^\/\.\.$]         = '/';                     # /..       -> /
		$path ~~ s[\/$]              = '' unless $path eq "/";  # xx/       -> xx
		return "$node$path";
	}

	method catdir( @parts ) { self.canonpath( (@parts, '').join('/') ) }

	method catfile {
		
	}

	method curdir {
		'.'
	}

	method devnull { '/dev/null' }

	method rootdir { '/' }

	my $tmpdir;
	method _tmpdir( *@dirlist ) {
		return $tmpdir if $tmpdir.defined;
		for @dirlist -> $dir {
			next unless $dir.defined && $dir.IO.d && $dir.IO.w;
			$tmpdir = $dir;
			last;
		}
		$tmpdir = self.curdir unless $tmpdir.defined;
		#$tmpdir = $tmpdir.defined && self.canonpath( $tmpdir );
		return $tmpdir;
	}
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = self._tmpdir( %*ENV{'TMPDIR'}, '/tmp' );
	}

	method updir { '..' }

	method no_upwards {
		
	}

	method case_tolerant {
		
	}

	method file_name_is_absolute {
		
	}

	method path {
		
	}

	method join {
		
	}

	method splitpath {
		
	}

	method splitdir {
		
	}

	method catpath {
		
	}

	method abs2rel {
		
	}

	method rel2abs {
		
	}
}

1;

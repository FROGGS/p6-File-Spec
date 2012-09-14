
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

	method catdir( *@parts ) { self.canonpath( (@parts, '').join('/') ) }

	method catfile( *@parts is copy ) {
		my $file = self.canonpath( @parts.pop );
		return $file unless @parts.elems;
		my $dir  = self.catdir( @parts );
		$dir    ~= '/' unless $dir.substr(*-1) eq '/';
		return $dir ~ $file;
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
		$tmpdir = $tmpdir.defined && self.canonpath( $tmpdir );
		return $tmpdir;
	}
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = self._tmpdir( %*ENV{'TMPDIR'}, '/tmp' );
	}

	method updir { '..' }

	method no_upwards( *@paths ) {
		my @no_upwards = grep { $_ !~~ /^[\.|\.\.]$/ }, @paths;
		return @no_upwards;
	}

	method case_tolerant { 0 }

	method file_name_is_absolute( $file ) {
		$file ~~ m/^\//
	}

	method path {
		return () unless %*ENV{'PATH'};
		my @path = %*ENV{'PATH'}.split( ':' );
		for @path {
			$_ = '.' if $_ eq ''
		}
		return @path
	}

	method join( *@parts ) {
		self.catfile( @parts )
	}

	method splitpath( $path, $nofile ) {
		my ( $volume, $directory, $file ) = ( '', '', '' );

		if $nofile {
			$directory = $path;
		}
		else {
			$path      ~~ m/^ ( [ .* \/ [ \.\.?$ ]? ]? ) (<-[\/]>*) /;
			$directory = $0;
			$file      = $1;
		}

		return ( $volume, $directory, $file );
	}

	method splitdir( $path ) {
		return $path.split( /\// )
	}

	method catpath( $volume, $directory is copy, $file ) {
		if $directory               ne ''
		&& $file                    ne ''
		&& $directory.substr( *-1 ) ne '/'
		&& $file.substr( 0, 1 )     ne '/' {
			$directory ~= "/$file"
		}
		else {
			$directory ~= $file
		}

		return $directory
	}

	method abs2rel( $path is copy, $base is copy = Str ) {
		$base = $*CWD unless $base.defined && $base.chars;

		$path = self.canonpath( $path );
		$base = self.canonpath( $base );

		if self.file_name_is_absolute($path) || self.file_name_is_absolute($base) {
			$path = self.rel2abs( $path );
			$base = self.rel2abs( $base );
		}
		else {
			# save a couple of cwd()s if both paths are relative
			$path = self.catdir( '/', $path );
			$base = self.catdir( '/', $base );
		}

		my ($path_volume, $path_directories) = self.splitpath( $path, 1 );
		my ($base_volume, $base_directories) = self.splitpath( $base, 1 );

		# Can't relativize across volumes
		return $path unless $path_volume eq $base_volume;

		# For UNC paths, the user might give a volume like //foo/bar that
		# strictly speaking has no directory portion.  Treat it as if it
		# had the root directory for that volume.
		if !$base_directories.chars && self.file_name_is_absolute( $base ) {
			$base_directories = self.rootdir;
		}

		# Now, remove all leading components that are the same
		my @pathchunks = self.splitdir( $path_directories );
		my @basechunks = self.splitdir( $base_directories );

		if $base_directories eq self.rootdir {
			@pathchunks.shift;
			return self.canonpath( self.catpath('', self.catdir( @pathchunks ), '') );
		}

		while @pathchunks && @basechunks && @pathchunks[0] eq @basechunks[0] {
			@pathchunks.shift;
			@basechunks.shift;
		}
		return self.curdir unless @pathchunks || @basechunks;

		# $base now contains the directories the resulting relative path 
		# must ascend out of before it can descend to $path_directory.
		my $result_dirs = self.catdir( self.updir() xx @basechunks.elems, @pathchunks );
		return self.canonpath( self.catpath('', $result_dirs, '') );
	}

	method rel2abs( $path is copy, $base is copy = Str ) {
		# Clean up $path
		if !self.file_name_is_absolute( $path ) {
			# Figure out the effective $base and clean it up.
			if !$base.defined || $base eq '' {
				$base = $*CWD;
			}
			elsif !self.file_name_is_absolute( $base ) {
				$base = self.rel2abs( $base )
			}
			else {
				$base = self.canonpath( $base )
			}

			# Glom them together
			$path = self.catdir( $base, $path )
		}

		return self.canonpath( $path )
	}
}

1;

class File::Spec::Unix;

method canonpath( $path is copy ) {
	return unless $path.defined;

	# Handle POSIX-style node names beginning with double slash (qnx, nto)
	# (POSIX says: "a pathname that begins with two successive slashes
	# may be interpreted in an implementation-defined manner, although
	# more than two leading slashes shall be treated as a single slash.")
	my $node = '';
	my $double_slashes_special = $*OS eq 'qnx' || $*OS eq 'nto';


	if $double_slashes_special
	&& ( $path ~~ s {^ ( '//' <-[ '/' ]>+ ) '/'? $} = '' || $path ~~ s { ^ ( '//' <-[ '/' ]>+ ) '/' } = '/' ) {
		$node = $0;
	}

	# xx////xx  -> xx/xx
	$path ~~ s:g { '/'+ }       = '/';

	# xx/././xx -> xx/xx
	$path ~~ s:g { '/.'+ '/' }  = '/';

	# xx/././xx -> xx/xx
	$path ~~ s:g { '/.'+ $ }    = '/';

	# ./xx      -> xx
	unless $path eq "./" {
		$path ~~ s { ^ './'+ }  = '';
	}

	# /../../xx -> xx
	$path ~~ s { ^ '/' '../'+ } = '/';

	# /..       -> /
	$path ~~ s { ^ '/..' $ }    = '/';

	# xx/       -> xx
	unless $path eq "/" {
		$path ~~ s { '/' $ }    = '';
	}

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

method _tmpdir( *@dirlist ) {
	my $tmpdir = @dirlist.first: { .defined && .IO.d && .IO.w }
		or fail "No viable candidates for a temporary directory found";
	self.canonpath( $tmpdir );
}

method tmpdir {
	state $tmpdir;
	return $tmpdir if $tmpdir.defined;
	return $tmpdir = self._tmpdir(
				%*ENV{'TMPDIR'},
				'/tmp',
				self.curdir
	                 );
}

method updir { '..' }

method no_upwards( *@paths ) {
	my @no_upwards = grep { $_ !~~ /^[\.|\.\.]$/ }, @paths;
	return @no_upwards;
}

method default_case_tolerant { False }

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

method splitpath( $path, $nofile = False ) {
	my ( $volume, $directory, $file ) = ( '', '', '' );

	if $nofile {
		$directory = $path;
	}
	else {
		$path      ~~ m/^ ( [ .* \/ [ '.'**1..2 $ ]? ]? ) (<-[\/]>*) /; 
		$directory = ~$0;
		$file      = ~$1;
	}
	$directory ~~ s/<?after .> '/'+ $ //; #/

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

method case_tolerant (Str:D $path = $*CWD, $write_ok as Bool = True ) {
	# This code should be platform independent, but feel free to add local override

	$path.path.e or fail "Invalid path given";
	my @dirs = self.splitdir(self.rel2abs($path));
	my @searchabledirs;

	# try looking at each component of $path to see if has letters
	loop (my $i = +@dirs; $i--; $i <= 0) {
		my $p = self.catdir(@dirs[0..$i]);
		push(@searchabledirs, $p) if $p.path.d;

		last if $p.IO.l;
		next unless @dirs[$i] ~~ /<.alpha>/;

		return self.case_tolerant_folder: @dirs[0..($i-1)], @dirs[$i];
	}

	# If nothing in $path contains a letter, search for nearby files, including up the tree
	# This doesn't actually look recursively; don't want to add File::Find as a dependency
	for @searchabledirs -> $d {
		my @filelist = $d.path.contents.grep(/<.alpha>/);
		next unless @filelist.elems;

		# anything with <alpha> will do
		return self.case_tolerant_folder: $d, @filelist[0];
	}

	# If we couldn't find anything suitable, try writing a test file
	if $write_ok {
		for @searchabledirs.grep({.path.w}) -> $d {
			my $filelc = self.catdir( $d, 'filespec.tmp');  #because 8.3 filesystems...
			my $fileuc = self.catdir( $d, 'FILESPEC.TMP');
			if $filelc.path.e or $fileuc.path.e { die "Wait, where did the file matching <alpha> come from??"; }
			try {
				spurt $filelc, 'temporary test file for p6 File::Spec, feel free to delete';
				my $result = $fileuc.path.e;
				unlink $filelc;
				return $result;
			}
			CATCH { unlink $filelc unless $filelc.path.e; }
		}
	}

	# Okay, we don't have write access... give up and just return the platform default
	return self.default_case_tolerant;

}

method case_tolerant_folder( \updirs, $curdir ) {
	return False unless self.catdir( |updirs, $curdir.uc).path.e
			 && self.catdir( |updirs, $curdir.lc).path.e;
	return +self.catdir(|updirs).path.contents.grep(/:i ^ $curdir $/) <= 1;
	# this could be faster by comparing inodes of .uc and .lc
	# but we can't guarantee POSIXness of every platform that calls this
}


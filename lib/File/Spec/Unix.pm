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

method curdir {	'.'  }
method updir  { '..' }
method rootdir { '/' }
method devnull { '/dev/null' }
method default-case-tolerant { $*OS eq 'darwin' }

method _firsttmpdir( *@dirlist ) {
	my $tmpdir = @dirlist.first: { .defined && .IO.d && .IO.w }
		or fail "No viable candidates for a temporary directory found";
	self.canonpath( $tmpdir );
}

method tmpdir {
	state $tmpdir;
	return $tmpdir if $tmpdir.defined;
	return $tmpdir = self._firsttmpdir(
				%*ENV{'TMPDIR'},
				'/tmp',
				self.curdir
	                 );
}

method no-upwards( *@paths ) {
	my @no_upwards = grep { $_ !~~ /^[\.|\.\.]$/ }, @paths;
	return @no_upwards;
}

method file-name-is-absolute( $file ) {
	so $file ~~ m/^\//
}

method path {
	return () unless %*ENV{'PATH'};
	my @path = %*ENV{'PATH'}.split( ':' );
	for @path {
		$_ = '.' if $_ eq ''
	}
	return @path
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

	return ( $volume, $directory, $file );
}

method split (Mu:D $path is copy ) {
	my ( $volume, $directory, $file ) = ( '', '', '' );

	$path      ~~ s/<?after .> '/'+ $ //;
	$path      ~~ m/^ ( [ .* \/ ]? ) (<-[\/]>*) /;
	$directory = ~$0;
	$file      = ~$1;
	$directory ~~ s/<?after .> '/'+ $ //; #/

	$file = '/'      if $directory eq '/' && $file eq '';
	$directory = '.' if $directory eq ''  && $file ne '';
	    # shell dirname '' produces '.', but we don't because it's probably user error

	return ( $volume, $directory, $file );
}


method join ($volume, $directory is copy, $file) {
	$directory = '' if all($directory, $file) eq '/'
                        or $directory eq '.' && $file.chars;
	self.catpath($volume, $directory, $file);
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

method catdir( *@parts ) { self.canonpath( (@parts, '').join('/') ) }

method splitdir( $path ) {
	return $path.split( /\// )
}

method catfile( *@parts is copy ) {
	my $file = self.canonpath( @parts.pop );
	return $file unless @parts.elems;
	my $dir  = self.catdir( @parts );
	$dir    ~= '/' unless $dir.substr(*-1) eq '/';
	return $dir ~ $file;
}

method abs2rel( $path is copy, $base is copy = Str ) {
	$base = $*CWD unless $base.defined && $base.chars;

	$path = self.canonpath( $path );
	$base = self.canonpath( $base );

	if self.file-name-is-absolute($path) || self.file-name-is-absolute($base) {
		$path = self.rel2abs( $path );
		$base = self.rel2abs( $base );
	}
	else {
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
	if !$base_directories.chars && self.file-name-is-absolute( $base ) {
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

method rel2abs( $path, $base is copy = $*CWD) {
	return self.canonpath($path) if self.file-name-is-absolute($path);
	if !self.file-name-is-absolute( $base ) {
		$base = self.rel2abs( $base )
	}
	self.catdir( $base, $path );
}

method case-tolerant (Str:D $path = $*CWD, $write_ok as Bool = True ) {
	# This code should be platform independent, but feel free to add local override

	$path.IO.e or fail "Invalid path given";
	my @dirs = self.splitdir(self.rel2abs($path));
	my @searchabledirs;

	# try looking at each component of $path to see if has letters
	loop (my $i = +@dirs; $i--; $i <= 0) {
		my $p = self.catdir(@dirs[0..$i]);
		push(@searchabledirs, $p) if $p.IO.d;

		last if $p.IO.l;
		next unless @dirs[$i] ~~ /<+alpha-[_]>/;

		return self!case-tolerant-folder: @dirs[0..($i-1)], @dirs[$i];
	}

	# If nothing in $path contains a letter, search for nearby files, including up the tree
	# This doesn't actually look recursively; don't want to add File::Find as a dependency
	for @searchabledirs -> $d {
		my @filelist = dir($d).grep(/<+alpha-[_]>/);
		next unless @filelist.elems;

		# anything with <alpha> will do
		return self!case-tolerant-folder: $d, @filelist[0];
	}

	# If we couldn't find anything suitable, try writing a test file
	if $write_ok {
		for @searchabledirs.grep({.IO.w}) -> $d {
			my $filelc = self.catdir( $d, 'filespec.tmp');  #because 8.3 filesystems...
			my $fileuc = self.catdir( $d, 'FILESPEC.TMP');
			if $filelc.IO.e or $fileuc.IO.e { die "Wait, where did the file matching <alpha> come from??"; }
			try {
				spurt $filelc, 'temporary test file for p6 File::Spec, feel free to delete';
				my $result = $fileuc.IO.e;
				unlink $filelc;
				return $result;
			}
			CATCH { unlink $filelc if $filelc.IO.e; }
		}
	}

	# Okay, we don't have write access... give up and just return the platform default
	return self.default-case-tolerant;

}

method !case-tolerant-folder( \updirs, $curdir ) {
	return False unless self.catdir( |updirs, $curdir.uc).IO.e
			 && self.catdir( |updirs, $curdir.lc).IO.e;
	return +dir(self.catdir(|updirs)).grep(/:i ^ $curdir $/) <= 1;
	# this could be faster by comparing inodes of .uc and .lc
	# but we can't guarantee POSIXness of every platform that calls this
}


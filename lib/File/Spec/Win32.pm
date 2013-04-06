use v6;
use File::Spec::Unix;
class File::Spec::Win32 is File::Spec::Unix;

my $module = "File::Spec::Unix";
#require $module;

# Some regexes we use for path splitting
my $driveletter = regex { <[A..Z a..z]> ':' }
my $slash	= regex { '/' | '\\' }
my $UNCpath     = regex { [<$slash> ** 2] <-[\\\/]>+  <$slash>  [<-[\\\/]>+ | $] }
my $volume_rx   = regex { $<driveletter>=<$driveletter> | $<UNCpath>=<$UNCpath> }


method canonpath ($path)         { canon_cat($path)               }

method catdir(*@dirs)            {
	# Legacy / compatibility support
	return "" unless @dirs;
	return canon_cat( "\\", |@dirs )
		if @dirs[0] eq "";

	# Compatibility with File::Spec <= 3.26:
	#     catdir('A:', 'foo') should return 'A:\foo'.
	if @dirs[0] ~~ /^<$driveletter>$/ {
		return canon_cat( (@dirs[0]~'\\'), |@dirs[1..*] )
	}
	return canon_cat(|@dirs);
}

method catfile(|c)           { self.catdir(|c)                     }
method curdir                { ::($module).curdir()                }
method devnull               { 'nul'                               }
method rootdir               { '\\'                                }


method tmpdir {
	state $tmpdir;
	return $tmpdir if $tmpdir.defined;
	$tmpdir = ::($module)._tmpdir(
		%*ENV<TMPDIR>,
		%*ENV<TEMP>,
		%*ENV<TMP>,
		'SYS:/temp',
		'C:\system\temp',
		'C:/temp',
		'/tmp',
		'/',
		self.curdir
	);
}

method updir                     { ::($module).updir()                   }
method no_upwards(|c)            { ::($module).no_upwards(|c)            }
#method case_tolerant(|c)         { ::($module).case_tolerant(|c)            }
method default_case_tolerant     { True                                     }

method file_name_is_absolute ($path) {
	# As of right now, this returns 2 if the path is absolute with a
	# volume, 1 if it's absolute with no volume, 0 otherwise.
	given $path {
		when /^ [<$driveletter> <$slash> | <$UNCpath>]/ { 2 }
		when /^ <$slash> /                              { 1 }
		default 					{ 0 }
	}   #/
}

method path {
	my @path = split(';', %*ENV<PATH>);
	@path».=subst(:global, q/"/, '');
	@path = grep *.chars, @path;
	unshift @path, ".";
	return @path;
}

method join(|c)                  { self.catfile(|c)                }

method splitpath($path as Str, $nofile as Bool = False) { 

	my ($volume,$directory,$file) = ('','','');
	if ( $nofile ) {
		$path ~~ 
		    /^ (<$volume_rx>?) (.*) /;
		$volume    = ~$0;
		$directory = ~$1;
	}
	else {
		$path ~~ 
		    m/^ ( <$volume_rx> ? )
			( [ .* <$slash> [ '.' ** 1..2 $]? ]? )
			(.*)
		     /;
		$volume    = ~$0;
		$directory = ~$1;
		$file      = ~$2;
	}

	return ($volume,$directory,$file);
}

method path-components($path as Str is copy) { 

	my ($volume, $directory, $file) = ('','','');
	$path ~~ s[ <$slash>+ $] = ''                       #=
		unless $path ~~ /^ <$driveletter>? <$slash>+ $/;

	$path ~~ 
	    m/^ ( <$volume_rx> ? )
		( [ .* <$slash> ]? )
		(.*)
	     /;
	$volume    = ~$0;
	$directory = ~$1;
	$file      = ~$2;
        $directory ~~ s/ <?after .> <$slash>+ $//;

	return ($volume,$directory,$file);
}

method join-path (|c) { self.catpath(|c)  }

method splitdir($dir)            { $dir.split($slash)                    }
method catpath($volume is copy, $directory, $file) {

	# Make sure the glue separator is present
	# unless it's a relative like A:foo.txt
	if $volume ne ''
	   and $volume !~~ /^<$driveletter>/
	   and $volume !~~ /<$slash> $/
	   and $directory !~~ /^ <$slash>/
		{ $volume ~= '\\' }
	if $file ne '' and $directory ne ''
	   and $directory !~~ /<$slash> $/
		{ $volume ~ $directory ~ '\\' ~ $file; }
	else 	{ $volume ~ $directory     ~    $file; }
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


method rel2abs ($path is copy, $base? is copy) {

	my $is_abs = self.file_name_is_absolute($path);

	# Check for volume (should probably document the '2' thing...)
	return self.canonpath( $path ) if $is_abs == 2;

	if $is_abs {
		# It's missing a volume, add one
		my $vol;
		$vol = self.splitpath($base)[0] if $base.defined;
		$vol ||= self.splitpath($*CWD)[0];
		return self.canonpath( $vol ~ $path );
	}

	if $base.not || $base eq '' {
		# TODO: implement _getdcwd call ( Windows maintains separate CWD for each volume )
		#$base = Cwd::getdcwd( ($self->splitpath( $path ))[0] ) if defined &Cwd::getdcwd ;
		#$base = $*CWD unless defined $base ;
		$base = $*CWD;
	}
	elsif ( !self.file_name_is_absolute( $base ) ) {
		$base = self.rel2abs( $base );
	}
	else {
		$base = self.canonpath( $base );
	}

	my ($path_directories, $path_file) = self.splitpath( $path, False )[1..2] ;

	my ($base_volume, $base_directories) = self.splitpath( $base, True ) ;

	$path = self.catpath( 
				$base_volume, 
				self.catdir( $base_directories, $path_directories ), 
				$path_file
				) ;

	return self.canonpath( $path ) ;
}


sub canon_cat ( $first is copy, *@rest ) {

	my $volumematch =
	     $first ~~ /^ ([   <$driveletter> <$slash>?
			    | <$UNCpath>
			    | [<$slash> ** 2] <-[\\\/]>+
			    | <$slash> ])?
			   (.*)
			/;
	my $volume = ~$volumematch[0];
	$first =     ~$volumematch[1];

	$volume.=subst(:g, '/', '\\');
	if $volume ~~ /^<$driveletter>/ {
		$volume.=uc;
	}
	else {
		$volume ~~ /<-[\\\/]>$/ and $volume ~= '\\';
		$volume ~~ /^<[\\\/]>$/ and $volume = '\\'; #::
	}

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

	$path ~~ s/^ '\\'+ //;		# \xx --> xx  NOTE: this is *not* root
	$path ~~ s/ '\\'+ $//;		# xx\ --> xx


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





use File::Spec::Unix;
class File::Spec::VMS is File::Spec::Unix;

my $module = "File::Spec::Unix";

my $unix_report = _unix_rpt;
my $dir_rx = regex {   '[' ~ ']'  <-[ \] ]>*
                     | '<' ~ '>'  <-[ \< ]>*
                   };


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
	            ?? self._firsttmpdir('/tmp', '/sys$scratch', %*ENV<TMPDIR>)
	            !! self._firsttmpdir( 'sys$scratch:', %*ENV<TMPDIR> );
}

method splitpath ($path, $nofile = False) {
	my ($dev, $dir, $file) = ('','','');
	#my $vmsify_path = vmsify($path);
	#VMSify is NYI, so...
	my $vmsify_path = $path;

	if $nofile {
		#vmsify('d1/d2/d3') returns '[.d1.d2]d3'
		#vmsify('/d1/d2/d3') returns 'd1:[d2]d3'
		if $vmsify_path ~~ /^ (.*) ']' (.+) $/ {
		    $vmsify_path = $1 ~ '.' ~ $2 ~ ']';
		}
		$vmsify_path ~~ /^ (.+ ':')?(.*) $/;
		$dir = ~$1 // ''; # dir can be '0'
		return (~$0 ,$dir, '');
	}
	else {
		$vmsify_path ~~ /^ (.+ ':')? ( <$dir_rx> )? (.*) $/;
		return (~$0 || '', ~$1 || '', ~$2);
	}
}

method split ($path, $nofile = False) {
	#really, this is function is more proof-of-concept than anything workable.
	# we need VMSify to do a good job here
	my ($dev, $dir, $file) = ('','','');
	#my $vmsify_path = vmsify($path);
	#VMSify is NYI, so...
	my $vmsify_path = $path;

	if 0 {
		#vmsify('d1/d2/d3') returns '[.d1.d2]d3'
		#vmsify('/d1/d2/d3') returns 'd1:[d2]d3'
		if $vmsify_path ~~ /^ (.*) ']' (.+) $/ {
		    $vmsify_path = $1 ~ '.' ~ $2 ~ ']';
		}
		$vmsify_path ~~ /^ (.+ ':')?(.*) $/;
		$dir = ~$1 // ''; # dir can be '0'
		return (~$0 ,$dir, '');
	}

	$vmsify_path ~~ /^ (.+ ':')? ( <$dir_rx> )? (.*) $/;
	($dev, $dir, $file) = (~$0 , ~$1 , ~$2);
	if $dir ne '' and $file eq '' {
		#should really do splitdir/catdir instead...
		my @chunks = $dir.split('.');
		if +@chunks > 1 {
			$file = '[' ~ @chunks.pop;
			$dir =   @chunks.join('.') ~ ']';
		}
		else {
			$file = $dir;
			$dir = '';
		}
	}
	return ($dev, $dir, $file);
}


method catpath ( $dev is copy, $dir is copy, $file ) {
    
	# We look for a volume in $dev, then in $dir, but not both
	my ($dir_volume, $dir_dir, $dir_file) = self.splitpath($dir);
	$dev = $dir_volume unless $dev ne '';
	$dir = $dir_file.chars ?? self.catfile($dir_dir, $dir_file) !! $dir_dir;

	if $dev ~~ /^ '/+' ( <-[/]>+ )/    { $dev = "$1:"; }  #'
	else { $dev ~= ':' unless $dev eq '' or $dev ~~ /':' $/; }
	if ($dev.chars or $dir.chars) {
						
		$dir = "[$dir]" unless $dir ~~ /<!after '^'> <[ "[</" ]>/;  #"
		#$dir = vmspath($dir);
	}
	$dir = '' if $dev.chars && $dir eq any('[]', '<>');
	"$dev$dir$file";
}

method join ($dev, $dirname is copy, $basename is copy) {
	if $dirname ne '' and $basename ~~ /^ '['/ {
		$basename ~~ s/^ '['//;
		$dirname  ~~ s/']' $/.$basename/;
		$basename = '';
	}
	self.catpath($dev, $dirname, $basename);
}

method canonpath             { ::($module).canonpath()             }
method catdir                { ::($module).catdir()                }
method catfile               { ::($module).catfile()               }
method curdir                { $unix_report ?? '.' !! '[]'         }
method devnull               { $unix_report ?? '/dev/null' !! "_NLA0:" }
method rootdir               { ::($module).rootdir()               }
method updir                 { $unix_report ?? '..' !! '[-]'       }
method no-parent-or-current-test  { ::($module).no-parent-or-current-test }
method case_tolerant         { True                                }
method default_case_tolerant { True                                }
method splitdir              { ::($module).splitdir()              }
method abs2rel               { ::($module).abs2rel()               }
method rel2abs               { ::($module).rel2abs()               }

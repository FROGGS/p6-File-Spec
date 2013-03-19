class File::Spec;

my %module = (
	'MacOS'   => 'Mac',
	'MSWin32' => 'Win32',
	'os2'     => 'OS2',
	'VMS'     => 'VMS',
	'epoc'    => 'Epoc',
	'NetWare' => 'Win32', # Yes, File::Spec::Win32 works on NetWare.
	'symbian' => 'Win32', # Yes, File::Spec::Win32 works on symbian.
	'dos'     => 'OS2',   # Yes, File::Spec::OS2 works on DJGPP.
	'cygwin'  => 'Cygwin'
);

my $module = "File::Spec::" ~ (%module{$*OS} // 'Unix');

require $module;

method canonpath( $path )                   { ::($module).canonpath( $path )                   }
method catdir( *@parts )                    { ::($module).catdir( @parts )                     }
method catfile( *@parts )                   { ::($module).catfile( @parts )                    }
method curdir                               { ::($module).curdir()                             }
method devnull                              { ::($module).devnull()                            }
method rootdir                              { ::($module).rootdir()                            }
method tmpdir                               { ::($module).tmpdir()                             }
method updir                                { ::($module).updir()                              }
method no_upwards( *@paths )                { ::($module).no_upwards( @paths )                 }
#method case_tolerant                        { ::($module).case_tolerant()                      }
method file_name_is_absolute( $file )       { ::($module).file_name_is_absolute( $file )       }
method path                                 { ::($module).path()                               }
method join( *@parts )                      { ::($module).join( @parts )                       }
method splitpath( $path, $no_file = 0 )     { ::($module).splitpath( $path, $no_file )         }
method splitdir( $path )                    { ::($module).splitdir( $path )                    }
method catpath( $volume, $directoy, $file ) { ::($module).catpath( $volume, $directoy, $file ) }
method abs2rel( $path, $base = Str )        { ::($module).abs2rel( $path, $base )              }
method rel2abs( $path, $base = Str )        { ::($module).rel2abs( $path, $base )              }


method case_tolerant (Str:D $path = cwd(), $write_ok as Bool = True ) {

	$path.path.e or fail "Invalid path given";
	my @dirs = File::Spec.splitdir(File::Spec.canonpath($path));
	my @searchabledirs;
	my $can_inode = 0;  #  should be: so $path.path.inode;

	# try looking at each component of $path to see if has letters
	loop (my $i = +@dirs; $i--; $i <= 0) {
		my $p = File::Spec.catdir(@dirs[0..$i]);
		# say "$p:", $p.path.inode;
		push(@searchabledirs, $p) if $p.path.d;

		last if $p.IO.l;
		next unless @dirs[$i] ~~ /<.alpha>/;

		return case_tolerant_folder @dirs[0..($i-1)], @dirs[$i], $can_inode;
	}

	# If nothing in $path contains a letter, search for nearby files, including up the tree
	# This doesn't actually look recursively; don't want to add File::Find as a dependency
	for @searchabledirs -> $d {
		my @filelist = $d.path.contents.grep(/<.alpha>/);
		next unless @filelist.elems;

		# anything with <alpha> will do
		return case_tolerant_folder $d, @filelist[0], $can_inode;
	}

	# If we couldn't find anything suitable, try writing a test file
	if $write_ok {
		for @searchabledirs.grep({.path.w}) -> $d {
			my $filelc = File::Spec.catdir( $d, 'filespec.tmp');  #because 8.3 filesystems...
			my $fileuc = File::Spec.catdir( $d, 'FILESPEC.TMP');
			if $filelc.path.e or $fileuc.path.e { die "Wait, where did the file matching <alpha> come from??"; }
			try {
				spurt $filelc, 'temporary test file for p6 File::Spec, feel free to delete';
				my $result = $fileuc.path.e;
				unlink $filelc;
				return $result;
			}
			CATCH { unlink $filelc; }
		}
	}

	# Okay, we don't have write access... give up and just return the platform default
	return ::($module).case_tolerant;

}

sub case_tolerant_folder( \updirs, $curdir, $inode_works ) {
	if $inode_works {
		return File::Spec.catdir( |updirs, $curdir.uc).path.inode
			== File::Spec.catdir( |updirs, $curdir.lc).path.inode;
	}
	else {
		my $numdirs = +File::Spec.catdir(|updirs).path.contents.grep(/:i ^ $curdir $/);
		if $numdirs > 1 { return False; }
		else { return (File::Spec.catdir( |updirs, $curdir.uc).path.e
				&& File::Spec.catdir( |updirs, $curdir.lc).path.e ) };
	}
}



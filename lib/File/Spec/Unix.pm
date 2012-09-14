
module File::Spec::Unix;

class File::Spec::Unix {
	method canonpath {
		
	}

	method catdir {
		
	}

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

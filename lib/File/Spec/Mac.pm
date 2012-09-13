
module File::Spec::Mac;

BEGIN require "File::Spec::Unix";

role File::Spec::OS {
	# use Unix as a base
	also does File::Spec::Unix;

	# and add Mac specific stuff
	method curdir {
		':'
	}

	my $tmpdir;
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = self._tmpdir( %*ENV{'TMPDIR'} );
	}
}

1;

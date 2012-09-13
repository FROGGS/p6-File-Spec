
module File::Spec::Win32;

BEGIN require "File::Spec::Unix";

role File::Spec::OS {
	# use Unix as a base
	also does File::Spec::Unix;

	# and add Win32 specific stuff
	my $tmpdir;
	method tmpdir {
		return $tmpdir if $tmpdir.defined;
		$tmpdir = self._tmpdir(
			%*ENV{'TMPDIR'},
			%*ENV{'TEMP'},
			%*ENV{'TMP'},
			'SYS:/temp',
			'C:\system\temp',
			'C:/temp',
			'/tmp',
			'/'
		);
	}
}

1;

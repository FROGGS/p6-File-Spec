use File::Spec::Unix;
use File::Spec::Win32;
class File::Spec::Cygwin is File::Spec::Unix;

#| Any C<\> (backslashes) are converted to C</> (forward slashes),
#| and then File::Spec::Unix.canonpath() is called on the result.
method canonpath (Mu:D $path as Str is copy) {
	$path.=subst(:g, '\\', '/');

	# Handle network path names beginning with double slash
	my $node = '';
	if $path ~~ s★^ ('//' <-[/]>+) [ '/' | $ ]  ★/★ {
		$node = ~$0;
	}
	$node ~ File::Spec::Unix.canonpath($path);
}

#| Calls the Unix version, and additionally prevents
#| accidentally creating a //network/path.
method catdir ( *@paths ) {
	my $result = File::Spec::Unix.catdir(@paths);

	# Don't create something that looks like a //network/path
	$result.subst(/ <[\\\/]> ** 2..*/, '/');
}


#| Tests if the file name begins with C<drive_letter:/> or a slash.
sub file-name-is-absolute ($file) {
    so $file ~~ m★ ^ [<[A..Z a..z]>:]?  <[\\/]>★; # C:/test
}

method tmpdir {
    state $tmpdir;
    return $tmpdir if defined $tmpdir;
    $tmpdir = File::Spec::Unix._firsttmpdir(
		 %*ENV<TMPDIR>,
		 "/tmp",
		 %*ENV<TMP>,
		 %*ENV<TEMP>,
		 'C:/temp',
		 self.curdir );
}


#| Paths might have a volume, so we use Win32 splitpath and catpath instead
method splitpath (|c)         { File::Spec::Win32.splitpath(|c) }
method catpath (|c)           { File::Spec::Win32.catpath(|c).subst(:global, '\\', '/')  }
method split ($path)          { File::Spec::Win32.split($path)».subst(:global, '\\', '/')}
method join (|c)              { File::Spec::Win32.join(|c).subst(:global, '\\', '/')     }
method default-case-tolerant  { True                                }

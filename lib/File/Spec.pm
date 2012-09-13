
module File::Spec;

BEGIN {
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

	my $module = $module{$*OS} // 'Unix';

	require "File::Spec::$module";
};

class File::Spec {
	also does File::Spec::OS;
}

1;

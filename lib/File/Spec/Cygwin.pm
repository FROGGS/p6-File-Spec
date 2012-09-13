
module File::Spec::Cygwin;

role File::Spec::OS {
	method curdir {
		'.'
	}
}

1;

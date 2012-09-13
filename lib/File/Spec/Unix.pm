
module File::Spec::Unix;

# we need that so File::Spec::Mac can use it
role File::Spec::Unix {
	method curdir {
		'.'
	}
}

role File::Spec::OS {
	also does File::Spec::Unix;
}

1;

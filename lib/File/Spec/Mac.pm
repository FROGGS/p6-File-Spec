
module File::Spec::Mac;

BEGIN require "File::Spec::Unix";

role File::Spec::OS {
	# use Unix as a base
	also does File::Spec::Unix;

	# and add Mac specific stuff
	#method curdir {
	#	'3'
	#}
}

1;

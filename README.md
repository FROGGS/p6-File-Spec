p6-File-Spec
============

Usage:

	use File::Spec;
	say File::Spec.curdir;

Methods (current state):

	                       Unix   Mac   OS2  Win32  VMS
	canonpath
	catdir
	catfile
	curdir                 done  done        done      
	devnull                done  done        done      
	rootdir                done              done      
	tmpdir                 done  done        done      
	updir                  done  done        done      
	no_upwards
	case_tolerant
	file_name_is_absolute
	path
	join
	splitpath
	splitdir
	catpath
	abs2rel
	rel2abs
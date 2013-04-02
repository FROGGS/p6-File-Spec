p6-File-Spec
============

Usage:

	use File::Spec;
	say File::Spec.curdir;

Methods (current state):

	                       Unix   Mac   OS2  Win32  VMS Cygwin Epoc
	canonpath              done  done        done        done  done 
	catdir                 done              done        done  done
	catfile                done              done        done  done
	curdir                 done  done  done  done        done  done
	devnull                done  done  done  done        done  done
	rootdir                done        done  done        done  done
	tmpdir                 done  done        done        done  done
	updir                  done  done  done  done        done  done
	no_upwards             done              done        done  done
	case_tolerant          done  done  done  done  done  done  done
	file_name_is_absolute  done  done  done  done        done  done
	path                   done        done  done        done  done
	join                   done              done        done  done
	splitpath              done  done        done        done  done
	splitdir               done        done  done        done  done
	catpath                done              done        done  done
	abs2rel                done              done        done  done
	rel2abs                done              done        done  done
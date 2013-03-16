p6-File-Spec
============

Usage:

	use File::Spec;
	say File::Spec.curdir;

Methods (current state):

	                       Unix   Mac   OS2  Win32  VMS Cygwin Epoc
	canonpath              done  done        done                  
	catdir                 done              done      
	catfile                done              done      
	curdir                 done  done        done      
	devnull                done  done        done      
	rootdir                done              done      
	tmpdir                 done  done        done      
	updir                  done  done        done      
	no_upwards             done                        
	case_tolerant          done  done  done  done  done        done
	file_name_is_absolute  done  done        done                  
	path                   done                                    
	join                   done                                    
	splitpath              done  done        done                  
	splitdir               done              done                  
	catpath                done              done                  
	abs2rel                done                                    
	rel2abs                done                                    
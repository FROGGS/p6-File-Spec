p6-File-Spec
============

Usage:

	use File::Spec;
	say File::Spec.curdir;   #your current OS's curdir
	say File::Spec.os('Win32').rootdir   # "\" on any OS

Methods (current state):

	                          Unix   Mac   Win32  VMS Cygwin
	canonpath                 done  done   done        done
	no-parent-or-current-test done         done        done
	devnull                   done  done   done  done  done
	curdir                    done  done   done  done  done
	updir                     done  done   done  done  done
	rootdir                   done         done        done
	tmpdir                    done  done   done  done  done
	path                      done         done  done  done
	file-name-is-absolute     done  done   done  done  done
	split                     done         done   ~~   done
	join                      done         done   ~~   done
	splitpath                 done  done   done   ~~   done
	catpath                   done         done   ~~   done
	splitdir                  done         done        done
	catdir                    done         done        done
	catfile                   done         done        done
	abs2rel                   done         done        done
	rel2abs                   done         done        done

'~~' means partially implemented, but not passing tests.

## Ported methods

See [Perl 5 File::Spec](http://search.cpan.org/~smueller/PathTools-3.40/lib/File/Spec.pm) for now.  The methods are the same, but use dots instead of arrows.

## Removed methods

Method `no_updirs` is gone, because its use case is handled automatically by `dir()`.  For the test that supplies dir with its functionality, see new method `no-parent-or-current-test`.

Method `case_tolerant` has moved to its own module, [File::Spec::Case](https://github.com/labster/p6-File-Spec-Case), and slightly changed its interface.

## Changed methods

### join

The method `join` is no longer an alias for `catfile`, but instead a unique function similar to `catpath`.  See the description of join in the New methods section.

## New methods

### os

The os method takes a single argument, an operating system string, and returns a File::Spec object for the appropriate OS.

	my $mac_os_x_spec = File::Spec.os('darwin');
		# returns a File::Spec::Unix object
	my $windows_spec = File::Spec.os('MSWin32');
		#returns File::Spec::Win32
	say File::Spec.os('Win32').canonpath('C:\\foo\\.\\bar\\');
		# prints "C:\foo\bar"

The parameter can be either an operating system string, or the last part of the name of a subclass ('Win32', 'Mac').  The default is `$*OS`, which gives you the same subclass that File::Spec already uses for your system.


### split

A close relative of `splitdir`, this function also splits a path into volume, directory, and basename portions.  Unlike splitdir, path-components returns paths compatible with dirname and basename.

This means that trailing slashes will be eliminated from the directory and basename components, in Win32 and Unix-like environments.  The basename component will always contain the last part of the path, even if it is a directory, `'.'`, or `'..'`.  If a relative path's directory portion would otherwise be empty, the directory is set to `'.'`.

On systems with no concept of volume, returns `''` (the empty string) for volume.

	($volume, $directories, $basename) =
			File::Spec.split( $path );

The results can be passed to `.join` to get back a path equivalent to (but not necessarily identical to) the original path.  If you want to keep all of the characters involved, use `.splitdir` instead.

### Comparison of splitpath and split

	OS      Path       splitpath               split
	linux   /a/b/c     ("", "/a/b/", "c")      ("", "/a/b", "c")
	linux   /a/b//c/   ("", "/a/b//c/", "")    ("", "/a/b", "c")
	linux   /a/b/.     ("", "/a/b/.", "")      ("", "/a/b", ".")
	Win32   C:\a\b\    ("C:", "\\a\\b\\", "")  ("C:", "\\a", "b")
	VMS     A:[b.c]    ("A:", "[b.c]", "")     ("A:", "[b]", "[c]")


### join

A close relative of `.catpath`, this function takes volume, directory and basename portions and returns an entire path.  If the dirname is `'.'`, it is removed from the (relative) path output, because this function inverts the functionality of dirname and basename.

	$full-path = File::Spec.join($volume, $dirname, $basename);

Directory separators are inserted if necessary.  Under Unix, $volume is ignored, and only directory and basename are concatenated.  On other OSes, $volume is significant.

This method is the inverse of `.split`; the results can be passed to it to get the volume, dirname, and basename portions back.


### Comparison of catpath and join

	OS     Components            catpath        join
	linux  ("", "/a/b", "c")     /a/b/c         /a/b/c
	linux  ("", ".", "foo")      ./foo          foo
	linux  ("", "/", "/")        //             /
	Win32  ("C:", "\a", "b")     C:\a\b         C:\a\b
	VMS    ("A:", "[b]", "[c]")  A:[b][c]       A:[b.c]

### no-parent-or-current-test

Returns a test as to whether a given path is identical to the parent or the current directory.  The `dir()` function automatically removes these for you in directory listings, so under normal circumstances you shouldn't need to use it directly.

	'file' ~~ File::Spec.no-parent-or-current-test    #False
	'.'    ~~ File::Spec.no-parent-or-current-test    #True
	'..'   ~~ File::Spec.no-parent-or-current-test    #True

This can, however, be used to extend `dir()` through its `$test` parameter:

	dir( "my/directory", test=>
		all(File::Spec.no-parent-or-current-test, /^ '.' /));

This example would return all files begining with a period that are not `.` or `..` directories.

This replaces the functionality of the old `no-updirs` method.

use v6;
use File::Spec::Unix;
class File::Spec::Epoc is File::Spec::Unix;

my $module = "File::Spec::Unix";

method default_case_tolerant { True }
method case_tolerant         { True }

method canonpath ($path is copy) {
    return unless defined $path;

    $path ~~ s:g❙ '/'+ ❙/❙;                          # xx////xx  -> xx/xx
    $path ~~ s:g❙ '/.'+ '/' ❙/❙;                     #: xx/././xx -> xx/xx 
    $path ~~ s❙^ './'+❙❙ unless $path eq "./";       # ./xx      -> xx
    $path ~~ s❙^ '/' '../'+ ❙/❙;                     # /../../xx -> xx
    $path ~~  s❙ '/' $❙❙ unless $path eq "/";        # xx/       -> xx
    return $path;
}


=begin pod

This is a Perl6 port of all Perl 5's File::Spec has for Epoc.
Dead OS is dead. ⛼

See File::Spec::Win32 for Symbian support.

=end pod


use lib 'lib';
use Test;
use File::Spec;

plan 1;

# GitHub #1
my ( $volume, $dirs, $filename ) = File::Spec.splitpath('lib/Farabi.pm6');
is File::Spec.catpath( $volume, $dirs, $filename ), 'lib/Farabi.pm6', 'GitHub #1';

done;

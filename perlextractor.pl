use strict;
use warnings;

my $mdcitations = "";

my $pandoctmp = "mdbibexport.tmp";
open my $fm2, '<', $pandoctmp or die "Could not open '$pandoctmp' $!\n";

while (my $line = <$fm2>) {
   chomp $line;
   if ($line =~ /"citationId":"([^"]*)"/g){
   print "Extracted citation: $1\n";
   $mdcitations .= "$1,";
    }
}

print($mdcitations);

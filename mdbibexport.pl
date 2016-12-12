#!/usr/bin/perl
#Simple script to extract references from a bibtex database which are cited in a markdown file
#The installation of BibTool, Pandoc and Perl is required
#Version: 0.2
#Release: 2016/10/31
#Copyright: Dr. Robert Winkler
#Contributor: Alfred Krewinkel
#Contact: robert.winkler@bioprocess.org, robert.winkler@cinvestav.mx
#License: General Public License (GPL), 3.0

use strict;
use warnings;

print "Extract from markdown (.md) file: ";
my $namemd = <STDIN>;
chomp($namemd);
print "Extract from bibtex database (.bib) file: ";
my $namebib = <STDIN>;
chomp($namebib);

#mdbibexport files
my $nameaux = "mdbibexport.aux";
my $nameout = "mdbibexport.bib";


open my $fm, '<', $namemd or die "Could not open '$namemd' $!\n";

my $mdcitations = "";

system('pandoc -t json agile-editing-pandoc.md > mdbibexport.tmp');
my $pandoctmp = "mdbibexport.tmp";
open my $fm2, '<', $pandoctmp or die "Could not open '$pandoctmp' $!\n";

while (my $line = <$fm2>) {
   chomp $line;
   while ($line =~ /"citationId":"([^"]*)"/g){
   print "Extracted citation: $1\n";
   $mdcitations .= "$1,";
    }
}

open(my $fa, '>', $nameaux) or die;
print $fa "\\bibstyle{alpha}\n";
print $fa "\\bibdata{$namebib}\n";
print $fa "\\citation{$mdcitations}\n";
close $fa;
print "$nameaux created.\n";

my $btcmd = 'bibtool -x '. $nameaux . ' -o ' . $nameout;
system($btcmd);
print "$nameout created.\n";

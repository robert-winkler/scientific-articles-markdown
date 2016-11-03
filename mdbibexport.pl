#!/usr/bin/perl
#Simple script to extract references from a bibtex database which are cited in a markdown file
#The installation of BibTool is required
#Version: 0.1
#Release: 2016/10/31
#Copyright: Dr. Robert Winkler 
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
print "Choose name of temp .aux file (e.g. temp.aux): ";
my $nameaux = <STDIN>;
chomp($nameaux);
print "Choose name of output .bib file (e.g. out.bib): ";
my $nameout = <STDIN>;
chomp($nameout);

print "Choices: $namemd, $namebib, $nameaux, $nameout \n";

open my $fm, '<', $namemd or die "Could not open '$namemd' $!\n";

my $mdcitations = "";
while (my $line = <$fm>) {
   chomp $line;
   if ($line =~ /(?<=@)(.+?)(?=[\];,])/){
   $mdcitations .= "$1,"};
}

print "Extracted citations: $mdcitations \n";

open(my $fa, '>', $nameaux) or die;
print $fa "\\bibstyle{alpha}\n";
print $fa "\\bibdata{$namebib}\n";
print $fa "\\citation{$mdcitations}\n";
close $fa;
print "$nameaux created.\n";

my $btcmd = 'bibtool -x '. $nameaux . ' -o ' . $nameout;
system($btcmd);
print "$nameout created.\n";




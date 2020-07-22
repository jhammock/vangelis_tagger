#!/usr/bin/perl -w
use strict;
use warnings;

my $debug = 0;

die "Syntax: $0 <eol_text/eol_documents_ascii_nonHTML.notClean.txt> <eol_scripts/phrases_filter.tsv>" unless scalar(@ARGV) == 2;

$/ = undef; #undef input record separator to read the whole file as a string

## load phrases to substitute away
open TSV, "< $ARGV[1]" or die "Failed to read $ARGV[1]";
my @phrases = split /\n/, <TSV>;
close TSV;

## load eol documents as one string
open TXT, "< $ARGV[0]" or die "Failed to read $ARGV[0]";
my $eol_text = <TXT>;
close TXT;


##sustitute the phases away
foreach my $phrase ( @phrases )
{
    next if $phrase eq ""; #skip any empty lines added by mistake
    next if $phrase =~ m/^#/; #skip comments

    my $pattern = qr/$phrase/;
    $eol_text =~ s/$pattern/ /gi;
}


##remove new lines (\n) erroneously added by the utf8-html to ascii-plain text conversion
$eol_text =~ s/\n/__NEW_LINE_TAG__/g;
$eol_text =~ s/__NEW_LINE_TAG__EOL:/\nEOL:/g;
$eol_text =~ s/__NEW_LINE_TAG__/ /g;

#reprint
print $eol_text;
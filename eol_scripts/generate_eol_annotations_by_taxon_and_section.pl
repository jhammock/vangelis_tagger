#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $debug = 0;
my $index_debug = 0;

die "Syntax: $0 <eol_text_cpr_formatted.tsv> <eol_text_tags.tsv>" unless scalar(@ARGV) == 2;

## Data-structures
my %text_line_taxon_start_end_sections = ();

#load text document and make:
#    a. a byte index mapping text characters to taxon and section (section keys are held at their start coordinate)
#    b. a section-start-coordinate to taxon-and section-type index
my $line_counter = 0;
my $global_offset = 0;

open TSV, "< $ARGV[0]" or die "Failed to read $ARGV[0]";
while( my $line = <TSV>)  {
    
    $line_counter++;
    $line =~ s/\n//; #each line ends in \n - controlled by the merge text data and create CPR formatted EOL text file
    
    my @fields = split /\t/, $line;
    
    $text_line_taxon_start_end_sections{$line_counter}{ "taxon" } = $fields[0];
    $text_line_taxon_start_end_sections{$line_counter}{ "start" } = $global_offset;
    $text_line_taxon_start_end_sections{$line_counter}{ "end" } = $global_offset + length( $line);
    
    
    my $taxonid = $fields[0];
    for (my $i = 0; $i < scalar @fields; $i++) {
        
        #section-title and section-text start after the 6th field (inclusive)
        #the text to be indexed exists on 7th, 9th, 11th and so on field ([6], [8], [10] in Perl)
        if ($i >= 5 and $i %2 == 0) { #processing a text field where tags may be found
            my $start_coordinate = $global_offset;
            my $end_coordindate = $global_offset + length($fields[$i])-1;
            
            if ( $debug ) { print "DEBUG: 38:\t", $start_coordinate, "\t", $end_coordindate, "\n" ; }
            
            $text_line_taxon_start_end_sections{$line_counter}{ "sections" }{ $end_coordindate } = $fields[$i-1];
        }
        
        $global_offset += length($fields[$i])+1; #compensates for the "\t" removed by the split function and the "s/\n//" subsitution
    }
    
    
    if ($line_counter % 10000 ==0 ) {
        if ($debug) {
            print "\t".$line_counter."\n" unless $line_counter ==0;
        }
    }
    

}
close TSV;



# get all keys and store in array and remember the last position where an tag was found
# when a tag coordinate is found you dont need to search further
# since ENVIRONMENTS tag coordinates are sorted, the lines inspected for one tag-coordinate do not need to be inspected for the tag following it

my $print_counter = 0;
my $index_of_last_active_line_with_a_tag = 0; #index is 0-based, lines are 1-based
my @active_lines = sort { $a <=> $b} keys %text_line_taxon_start_end_sections;


#load NER-software predicted tags ("matches")
#output generate directly per tag
open TSV, "< $ARGV[1]" or die "Failed to read $ARGV[1]";
while (<TSV>) {
    
    my $prints_per_tag = 0; # used in debugging
    
    s/\r?\n//;

    my ($doc, $offset, $endpos, $str, $envo) = split /\t/;
    if ( $debug ) { print "DEBUG: 71:\t", $envo, "\t", $doc, "\t", $offset, "\t", $endpos ,"\t", $str, "\n" ; }
    

    #start looking from where the last tag-coordinate was found and onwards
    for (my $j = $index_of_last_active_line_with_a_tag; $j < scalar @active_lines; $j++ ) {
        
        my $tag_in_line = 0;
        
        my $line_number = $active_lines[$j];
        
        my $check_start = $text_line_taxon_start_end_sections{$line_number}{"start"};
        my $check_end = $text_line_taxon_start_end_sections{$line_number}{"end"};
        if ($offset >= $check_start and $offset <= $check_end){
            
            $tag_in_line = 1;
            
            foreach my $check_section_end (sort { $a <=> $b} keys %{ $text_line_taxon_start_end_sections{$line_number}{"sections"} })
            {

                $print_counter++ if $offset <= $check_section_end;
                $prints_per_tag++ if $offset <= $check_section_end;  # used in debugging
        
                #print output and quit checking the rest of the sections
                print   $text_line_taxon_start_end_sections{$line_number}{ "taxon" }."\t".$text_line_taxon_start_end_sections{$line_number}{"sections"}{$check_section_end}."\t".$str."\t".$envo."\n" if $offset <= $check_section_end;
                last if $offset <= $check_section_end;
            }
        }
        
        if ($debug) {
            print "DEBUG: 140:\t", $envo, "\t", $doc, "\t", $offset, "\t", $endpos ,"\t", $str, "\n" if  $prints_per_tag == 0 and $tag_in_line;
            print "DEBUG: 141:\t", "active line:\t".$line_number."\t".Dumper(\%{ $text_line_taxon_start_end_sections{$line_number}}), "\n" if  $prints_per_tag == 0 and $tag_in_line;
        }
        
        #set the active line index where the last tag-coordinate was found
        $index_of_last_active_line_with_a_tag =  $j if $tag_in_line;
        last if $tag_in_line;
        
    }
}#end of while reading line-by-line
close TSV;




if ($index_debug){
    print "%text_line_taxon_start_end_sections:\t ".Dumper(\%text_line_taxon_start_end_sections);
    print "@active_lines:\t ".Dumper(\@active_lines);
    
}
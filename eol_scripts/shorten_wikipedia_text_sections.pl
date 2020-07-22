#!/usr/bin/perl -w
use strict;
use warnings;

my $debug = 0;

# input: the eol text in cpr format
# output: the same eol text in cpr format merely with the wikipedia text sections shortened when applicable,
#         printed directly in the console
die "Syntax: $0 <eol_text_cpr_formatted.tsv>" unless scalar(@ARGV) == 1;



## Data-structures
my $WIKIPEDIA_ENTRY_CUT_OFF_LENGTH = 1500; # ~250 words, 250 * (5+1) = 1500, average english word length is 5 + 1 for a space right after)

## Procedure
#load text document
#for every line i.e. for every EOL taxon entry
#   for every field
#       if (field index >= 6 and field index %2 == 0
#               and field at [field index-1] ~= ;http://www.eol.org/voc/table_of_contents#Wikipedia)
#           shorten field
#       print field

my $line_counter = 0;
my $global_offset = 0;

open TSV, "< $ARGV[0]" or die "Failed to read $ARGV[0]";
while( my $line = <TSV>)  {
    
    $line_counter++;
    $line =~ s/\n//; #each line ends in \n - controlled by the merge text data and create CPR formatted EOL text file
    
    my @fields = split /\t/, $line;
    
    for (my $i = 0; $i < scalar @fields; $i++) {
        
        if ($i >= 6) {   #the first section text is contained in the 7th element of @fields (ie. $fields[6])
            if ($i %2 == 0) {   #$fields[6], $fields[8], $fields[10]... contain text sections
                if ( $fields[$i-1] =~ m/;http:\/\/www.eol.org\/voc\/table_of_contents#Wikipedia/) {
                    #the header field indicated this is a Wikipedia text section
                    
                    
                    if ($fields[$i] =~ m/Contents.*/) { #the page includes a table of contents
                        
                        #extract habitat and distribution clauses (if any)
                        my $habitat_clause = "";
                        my $distribution_clause = "";
                        my $distribution_and_habitat_clause = "";
                        
                        
                        if ($fields[$i] =~ m/Habitat\[edit\](.*?)(\[edit\]|$)/) {
                            $habitat_clause = $1;
                            print "\nHABITAT\t".$habitat_clause if $debug;
                        }
                            
                        if ($fields[$i] =~ m/Distribution\[edit\](.*?)(\[edit\]|$)/) {
                            $distribution_clause = $1;    
                            print "\nDIST\t".$distribution_clause if $debug;
                        }
                        
                        if ($fields[$i] =~ m/Distribution\ and\ habitat\[edit\](.*?)(\[edit\]|$)/) {
                            $distribution_and_habitat_clause = $1;    
                            print "\nDISTnHAB\t".$distribution_and_habitat_clause if $debug;
                        }
                        
                        #remove everything after Contents
                        $fields[$i] =~ s/Contents.*//;
                        
                        #append $habitat_distribution_clause (if any)
                        $fields[$i] = $fields[$i]." ".$habitat_clause unless $habitat_clause eq "";
                        $fields[$i] = $fields[$i]." ".$distribution_clause unless $distribution_clause eq "";
                        $fields[$i] = $fields[$i]." ".$distribution_and_habitat_clause unless $distribution_and_habitat_clause eq "";
                        
                    }
                    else { #The page does not include a table of contents
                        
                        #remove everything after References or Source (whatever comes first)
                        if ($fields[$i] =~ m/(References.*|Source.*)/) {
                            $fields[$i] =~ s/(References.*|Source.*)//;
                        }
                        
                        #in pages without a table of contents apply a length limit anyway
                        if (length $fields[$i] > $WIKIPEDIA_ENTRY_CUT_OFF_LENGTH) {
                            $fields[$i] = substr ( $fields[$i], 0, $WIKIPEDIA_ENTRY_CUT_OFF_LENGTH);
                        }
                    }
                }
            }
        }
        print $fields[$i];
        print "\t" unless ($i+1 == scalar @fields); #skip tab after the last field
    }# end for each field
    print "\n";
    
    
    if ($debug){
        if ($line_counter % 10000 == 0 ) {
            print "\t".$line_counter."\n" unless $line_counter ==0;
        }
    }
}#end for each line
close TSV;


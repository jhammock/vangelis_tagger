#!/usr/bin/perl -w

use strict;
my $debug = 0;
my $deep_debug = 0;

die "Syntax: $0 <matches> <hierarchy>" unless scalar(@ARGV) eq 2;

## Data-structures
my %child_parent = ();
my %doc_offset_endpos_str_envo = ();


## Procedure
#load child parent relationships
#initialize all terms in %doc_offset_endpos_str_envo to "1"
#set all parent terms to 0 and filter-out
#at the end all  remaining "1"s will be leaf-children terms
#print the latter

## Populate data-structures

#load the hierarchy as from the "child-parent relationships" flattened file
# Column 2 = child term ID ("ENVO:2000006" format)
# Column 5 = parent term ID ("ENVO:00002297" format)
open TSV, "< $ARGV[1]" or die "Failed to read $ARGV[1]";
while (<TSV>) {  
    s/\r?\n//;
    my (undef, $child, undef, undef, $parent,undef) = split /\t/;
    $child_parent{$child}{$parent} = 1;
    
    if ( $deep_debug ) { print "DEBUG: 25:\t", $child, "\t", $parent, "\n" ; }

}
close TSV;


#load NER-software predicted tags ("matches")
#NB: 'offset' is zero-based
#NB: 'endpos' is the index of the last character of the curated/tagged term
open TSV, "< $ARGV[0]" or die "Failed to read $ARGV[0]";
while (<TSV>) {
    next if /^\s*?#/; #skip commented lines (eg the header)
    s/\r?\n//;

    my ($doc, $offset, $endpos, $str, $envo) = split /\t/;
    $doc_offset_endpos_str_envo{$doc}{$offset}{$endpos}{$str}{$envo} = 1;
    
    if ( $deep_debug ) { print "DEBUG: 37:\t", $envo, "\t", $doc, "\t", $offset, "\t", $endpos ,"\t", $str, "\n" ; }

}
close TSV;

#process document-by-document
foreach my $current_doc (sort keys %doc_offset_endpos_str_envo)
{
    
    #flag all parent terms
    foreach my $current_offset (sort {$a<=>$b} keys %{ $doc_offset_endpos_str_envo{$current_doc}  })
    {
        foreach my $current_endpos (sort keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}  })
        {
            foreach my $current_str (sort keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos} })
            {
                foreach my $current_id (sort keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str} })
                {
                    if ( $debug ) {                    
                        print "#\t".$current_offset."\t".$current_endpos."\t".$current_str."\t".$current_id."\t";
                        print "parents:\t";
                        print join (", ", sort keys %{ $child_parent{$current_id} } );
                        print "\n";
                    }                    

                    foreach my $parent (sort keys %{ $child_parent{$current_id} } )
                    {
                        #consider only parent terms contained in standard ENVIRONMENTS output
                        #e.g. do not check "ENVO:root" that is used internally only by ENVIRONMENTS
                        next unless exists $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str}{$parent};
                        
                        #set parent terms to 0
                        $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str}{$parent} = 0;
                    }                    
                }
            }
        }
    }


    #print all non-parent terms    
    foreach my $current_offset (sort {$a<=>$b} keys %{ $doc_offset_endpos_str_envo{$current_doc}  })
    {
        foreach my $current_endpos (sort {$a<=>$b} keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}  })
        {
            foreach my $current_str (sort keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos} })
            {
                foreach my $current_id (sort keys %{ $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str} })
                {
                    if ( $debug) {
                        print "#: ".$current_doc."\t".$current_offset."\t".$current_endpos."\t".$current_str."\t".$current_id;
                        print "\t".$doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str}{$current_id};
                        print "\n";
                    }
                    
                    #skip parent terms
                    next unless $doc_offset_endpos_str_envo{$current_doc}{$current_offset}{$current_endpos}{$current_str}{$current_id} eq "1";
                    print $current_doc."\t".$current_offset."\t".$current_endpos."\t".$current_str."\t".$current_id."\n";
                    
                }
            }
        }
    }    
}#end of foreach $current_doc


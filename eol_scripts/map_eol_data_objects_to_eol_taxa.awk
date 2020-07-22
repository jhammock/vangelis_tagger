#! /usr/bin/gawk -f 

BEGIN {
    FS="\t";
}


## usage: ./eol_scripts/map_eol_data_objects_to_eol_taxa.awk <$extracted_data/eol_selected_text.tsv> > <$extracted_data/dataobjid_taxonid.sorted.tsv>


## process "$extracted_data/eol_selected_text.tsv"
#  field info from "meta.xml" (inherited from "media_resource.tab")
#    $1 == <field index="0" term="http://purl.org/dc/terms/identifier"/>
#    $2 == <field index="1" term="http://rs.tdwg.org/dwc/terms/taxonID"/>

(ARGIND==1){
    
    #skip header and any erroneous lines
    if ( $1 ~ /[a-zA-Z]+/ || $2 ~ /[a-zA-Z]+/) {
        next;
    }
    
    #output data object id, taxon id map
    split ($2, taxon_ids, ";")
    for ( i in taxon_ids ) {
        print $1"\t"taxon_ids[i];
    }
}
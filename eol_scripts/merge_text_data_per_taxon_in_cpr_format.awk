#! /usr/bin/gawk -f 
BEGIN {
    FS="\t";
    previous_taxonid=-1;
    current_taxon_text="";
}

## usage: ./eol_scripts/merge_text_data_per_taxon_in_cpr_format.awk <$extracted_data/taxon.tab>  <$extracted_data/eol_selected_text.tsv>  <$extracted_data/dataobjid_taxonid.sorted.tsv>  > <$extracted_data/eol_documents_utf8_html.tsv>



## process "taxon.tab"
#  field info from "meta.xml"
#    $1 == <field index="0" term="http://rs.tdwg.org/dwc/terms/taxonID"/>
#    $3 == <field index="2" term="http://rs.tdwg.org/dwc/terms/scientificName"/>
(ARGIND==1){
    taxonid_name[$1] = $3;
}

## process "selected_text.tsv"
#  field info from "meta.xml" (inherited from "media_resource.tab")
#    $1 == "media_resource.tab" :: <field index="0" term="http://purl.org/dc/terms/identifier"/>
#    $2 == "media_resource.tab" :: <field index="1" term="http://rs.tdwg.org/dwc/terms/taxonID"/>
#    $3 == "media_resource.tab" :: <field index="9" term="http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/CVterm"/>
#    $4 == "media_resource.tab" :: <field index="10" term="http://purl.org/dc/terms/title"/>
#    $5 == "media_resource.tab" :: <field index="11" term="http://purl.org/dc/terms/description"/>
(ARGIND==2){
    
    ##Output format:
    #"eol data object($1);text section type($3)"\t"title($4)\ description($5)"
    dataobjectid_all_text[$1] = $1";"$3"\t"$4" "$5; 
    
}

## process dataobjid_taxonid.sorted.tsv
#  field info from "meta.xml" (inherited from "media_resource.tab")
#    $1 == <field index="0" term="http://purl.org/dc/terms/identifier"/>
#    $2 == <field index="1" term="http://rs.tdwg.org/dwc/terms/taxonID"/>
(ARGIND==3){

    #new taxon clause occured    
    if ( $2 != previous_taxonid) {
        
        #print previous
        if (current_taxon_text != "") {
            print current_taxon_text;
        }
        
        #reset and initialize text
        previous_taxonid = $2;
        current_taxon_text = "EOL:"$2"\t\tEncyclopedia of Life\t\t"taxonid_name[$2];    
    }   
    current_taxon_text = current_taxon_text"\t"dataobjectid_all_text[$1];
}

END{
    print current_taxon_text;
}

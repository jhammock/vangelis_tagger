#! /usr/bin/gawk -f 
BEGIN {
    FS="\t";
}

## usage: ./eol_scripts/append_external_source_databject_url.awk <$SCRIPT_DIR"/eol_data/media_resource.tab>  <$SCRIPT_DIR"/eol_annotation_output/eol_env_annotations.tsv> > <$SCRIPT_DIR"/eol_annotation_output/eol_env_annotations.enchanced.tsv>
## usage: ./eol_scripts/append_external_source_databject_url.awk <$SCRIPT_DIR"/eol_data/media_resource.tab>  <$SCRIPT_DIR"/eol_annotation_output/eol_env_annotations_noParentTerms.tsv> > <$SCRIPT_DIR"/eol_annotation_output/eol_env_annotations_noParentTerms.enchanced.tsv>


## 2015-09-28, evangelos
# responding to a comment by Jennifer the bibliographic citation
# of the external source url has been added as an extra column at the end. The
# bibliographic citation originates from
#    http://services.eol.org/downloads/eol_archive_objects.tar.gz =>
#        media_resource.tab =>
#            <field index="16" term="http://purl.org/dc/terms/bibliographicCitation"/>
# the annotation file now reads, eg.
#     EOL:45858206	25111593;http://rs.tdwg.org/ontology/voc/SPMInfoItems#GeneralDescription;http://www.pensoft.net/journals/compcytogen/article/4320/abstract/	cleft	ENVO:00000526	Gavrilov-Zimin I (2012) A contribution to the taxonomy, cytogenetics and reproductive biology of the genus Aclerda Signoret (Homoptera, Coccinea, Aclerdidae) CompCytogen 6(4): 389Ð395
##



## 2015-09-25, evangelos
# a url citing the source an EOL Text object has now been added in the annotation file
# the external source url originates from
#    http://services.eol.org/downloads/eol_archive_objects.tar.gz =>
#        media_resource.tab =>
#            <field index="5" term="http://rs.tdwg.org/ac/terms/furtherInformationURL"/>
# and is being added as a third colon-separated component in the ENV-EOL
# annotation files, eg.
#     EOL:45858206	25111593;http://rs.tdwg.org/ontology/voc/SPMInfoItems#GeneralDescription;http://www.pensoft.net/journals/compcytogen/article/4320/abstract/	cleft	ENVO:00000526
##


## process "media_resource.tab"
#  field info from "meta.xml"
#    $1  == "media_resource.tab" :: <field index="0" term="http://purl.org/dc/terms/identifier"/>
#    $6  == "media_resource.tab" :: <field index="5" term="http://rs.tdwg.org/ac/terms/furtherInformationURL"/>
#    $17 == "media_resource.tab" :: <field index="16" term="http://purl.org/dc/terms/bibliographicCitation"/>
(ARGIND==1){
    dataobjectid_sourceURL[$1] = $6;
    dataobjectid_biblioCitation[$1] = $17;
}

## append external URL to "eol_env_annotations_noParentTerms.tsv / eol_env_annotations.tsv"
#  at the end of field 2 via a colon and print, maintaining all other fields as they are
(ARGIND==2){
    
    ## extract the eol data object id from field 2
    dobjid = -1;
    if ( match( $2, /^[0-9]+?/, m) ){
        dobjid = m[0];
    }
    
    ## print output 
    # format: "eol taxon id TAB data object id ; text section type ; externalSourceDataObjectURL TAB matched term TAB envo identifier TAB bibliographic citation
    # e.g. 
    # EOL:45858206	25111593;http://rs.tdwg.org/ontology/voc/SPMInfoItems#GeneralDescription;http://www.pensoft.net/journals/compcytogen/article/4320/abstract/	cleft	ENVO:00000526	Gavrilov-Zimin I (2012) A contribution to the taxonomy, cytogenetics and reproductive biology of the genus Aclerda Signoret (Homoptera, Coccinea, Aclerdidae) CompCytogen 6(4): 389Ð395
    print  $1"\t"$2";"dataobjectid_sourceURL[dobjid]"\t"$3"\t"$4"\t"dataobjectid_biblioCitation[dobjid];
}
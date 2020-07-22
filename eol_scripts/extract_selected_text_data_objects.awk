#! /usr/bin/gawk -f 
BEGIN {
    FS="\t";
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Distribution"]               = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#MolecularBiology"]       = 0;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#TypeInformation"]            = 0;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#Wikipedia"]                      = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Habitat"]                    = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#ConservationStatus"]         = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Conservation"]               = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Trends"]                 = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Threats"]                = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Management"]             = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Morphology"]             = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Associations"]           = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#GeneralDescription"]         = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#DiagnosticDescription"]  = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Description"]                = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Size"]                   = 0;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#Notes"]                      = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Cyclicity"]              = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Ecology"]                    = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#TaxonBiology"]               = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Uses"]                   = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#LifeExpectancy"]         = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#TrophicStrategy"]            = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Reproduction"]               = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Biology"]                    = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Key"]                    = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Use"]                    = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Behaviour"]                  = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#LifeCycle"]                  = 1;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#Taxonomy"]                   = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#PopulationBiology"]          = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#LookAlikes"]             = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Evolution"]              = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Dispersal"]                  = 1;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#FunctionalAdaptations"]      = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#RiskStatement"]          = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Genetics"]               = 0;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#EducationResources"]         = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Growth"]                 = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Legislation"]            = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Physiology"]                 = 1;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Diseases"]               = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Migration"]                  = 1;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#IdentificationResources"]    = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Cytology"]               = 0;
    eol_section_selected["http://eol.org/schema/eol_info_items.xml#TypeInformation"]                = 0;
    eol_section_selected["http://eol.org/schema/eol_info_items.xml#Taxonomy"]                   = 0;
    eol_section_selected["http://rs.tdwg.org/ontology/voc/SPMInfoItems#Procedures"]             = 0;
    eol_section_selected["http://eol.org/schema/eol_info_items.xml#Notes"]                          = 1;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#Development"]                    = 1;
    eol_section_selected["http://www.eol.org/voc/table_of_contents#SystematicsOrPhylogenetics"] = 0;
}



## usage: ./extract_selected_text_data_objects.awk <$extracted_data/media_resource.tab> > <$extracted_data/eol_selected_text.tsv>




## process "media_resource.tab"
#  field info from "meta.xml" 
## used in control statements
#    $3 == <field index="2" term="http://purl.org/dc/terms/type"/>
#    $13 == <field index="12" term="http://purl.org/dc/terms/language"/>

## used in print statement and some also in control statements
#    $1 == <field index="0" term="http://purl.org/dc/terms/identifier"/>
#    $2 == <field index="1" term="http://rs.tdwg.org/dwc/terms/taxonID"/>
#    $10 == <field index="9" term="http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/CVterm"/>
#    $11 == <field index="10" term="http://purl.org/dc/terms/title"/>
#    $12 == <field index="11" term="http://purl.org/dc/terms/description"/>

#process "media_resource.tab"
(ARGIND==1){

    #skip header and any erroneous lines
    if ( $1 ~ /[a-zA-Z]+/ || $2 ~ /[a-zA-Z]+/) {
        next;
    }


    #select text objects only (type is text)
    if ( $3 == "http://purl.org/dc/dcmitype/Text"){
    
        #written in english language
        if ($13 == "en"){
        
            #belonging to the selected sections ($10 field)
            if ( eol_section_selected[$10]) {
                print $1"\t"$2"\t"$10"\t"$11"\t"$12;
            }
        }
    }

}
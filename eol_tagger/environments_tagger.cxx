#include "document.h"
#include "match_handlers.h"
#include "batch_tagger.h"

using namespace std;

class EnvironmentsBatchHandler : public BatchHandler
{
	private:
		unordered_map<SERIAL, char*> serial_id;
	
	public:
		EnvironmentsBatchHandler(const char* entities_filename) : BatchHandler()
		{
			InputFile entities_file(entities_filename);
			while (true) {
				vector<char *> fields = entities_file.get_fields();
				int size = fields.size();
				if (size == 0) {
					break;
				}
				if (size >= 3) {
					SERIAL serial = atoi(fields[0]);
					int n = strlen(fields[2])+1;
					serial_id[serial] = new char(n);
					memcpy(serial_id[serial], fields[2], n);
				}
				for (vector<char*>::iterator it = fields.begin(); it != fields.end(); it++) {
					delete *it;
				}
			}
		}
		
		~EnvironmentsBatchHandler()
		{
			for (unordered_map<SERIAL, char*>::iterator it = serial_id.begin(); it != serial_id.end(); it++) {
				free(it->second);
			}
		}
		
		void on_match(Document& document, Match* match)
		{
			char replaced = document.text[match->stop+1];
			document.text[match->stop+1] = '\0';
			Entity* entity = match->entities;
			for (int i = 0; i < match->size; i++) {
				char* id = serial_id[entity->id.serial];
				if (strcmp(id, "ENVO:root")) {
					printf("%s\t%d\t%d\t%s\t%s\n", document.name, match->start, match->stop, (const char*)(document.text+match->start), id);
				}
				entity++;
			}
			document.text[match->stop+1] = replaced;
		};
};

////////////////////////////////////////////////////////////////////////////////

int main (int argc, char *argv[])
{
	assert(argc >= 2);

	EntityTypeMap* entity_type_map = new EntityTypeMap("environments_entities.tsv");
	BatchTagger batch_tagger;
	batch_tagger.load_names("environments_entities.tsv", "environments_names.tsv");
	batch_tagger.load_groups(entity_type_map, "environments_groups.tsv");
	batch_tagger.load_global("environments_global.tsv");
	
	DirectoryDocumentReader document_reader = DirectoryDocumentReader(argv[1]);
	GetMatchesParams params;
	params.auto_detect = false;
	params.entity_types.push_back(-27);
	params.max_tokens = 6;
	EnvironmentsBatchHandler batch_handler("environments_entities.tsv");
	
	batch_tagger.process(&document_reader, params, &batch_handler);	
}

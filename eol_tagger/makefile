CC     = g++
CFLAGS = -fpic -Wall -O3 -lpthread
LFLAGS = -fpic -shared -lboost_regex

all: environments_tagger

clean:
	rm -f environments_tagger

%: %.cxx acronyms.h document.h file.h hash.h mutex.h match_handlers.h base_handlers.h batch_tagger.h tagger.h tagger_core.h tagger_types.h tightvector.h tokens.h
	$(CC) $(CFLAGS) -lboost_regex -o $@ $< -lm

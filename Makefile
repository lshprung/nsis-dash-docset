DOCSET_NAME = NSIS

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ICON_FILE_2X    = $(DOCSET_DIR)/icon@2x.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

SRC_ICON = src/icon.png
SRC_ICON_2X = src/icon@2x.png

MANUAL_FILE = manual_src/manual.tar.gz

ERROR_DOCSET_NAME = $(error DOCSET_NAME is unset)
WARNING_MANUAL_URL = $(warning MANUAL_URL is unset)
ERROR_MANUAL_FILE = $(error MANUAL_FILE is unset)
.phony: err warn

ifndef DOCSET_NAME
err: ; $(ERROR_DOCSET_NAME)
endif

ifndef MANUAL_FILE
err: ; $(ERROR_MANUAL_FILE)
endif

ifndef MANUAL_URL
warn: 
	$(WARNING_MANUAL_URL)
	$(MAKE) all
endif

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE)
ifdef SRC_ICON
DOCSET += $(ICON_FILE)
endif
ifdef SRC_ICON_2X
DOCSET += $(ICON_FILE_2X)
endif

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index.sh $@ $(DOCUMENTS_DIR)/Docs/*.html
	src/index_sub_pages.sh $@ $(DOCUMENTS_DIR)/Docs/Contents.html

$(ICON_FILE): $(SRC_ICON) $(DOCSET_DIR)
	cp $(SRC_ICON) $@

$(ICON_FILE_2X): $(SRC_ICON_2X) $(DOCSET_DIR)
	cp $(SRC_ICON_2X) $@

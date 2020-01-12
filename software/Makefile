include env.make

NODEMCU-COMMAND=$(NODEMCU-UPLOADER) -b $(SPEED) --start_baud $(SPEED) -p $(PORT)

CACHE = .cache

LUA_FILES := $(wildcard *.lua)
LUA_CACHE := $(patsubst %.lua,$(CACHE)/%.upload,$(LUA_FILES))

AUDIO_FILES := $(wildcard samples/*.u8)
AUDIO_CACHE := $(patsubst %.u8,$(CACHE)/%.upload,$(AUDIO_FILES))

WWW_FILES := $(wildcard www/*)
WWW_CACHE := $(patsubst %,$(CACHE)/%.upload,$(WWW_FILES))

.PHONY: help
help:
	$(NODEMCU-COMMAND) upload --help

$(CACHE)/samples/%.upload: samples/%.u8
	mkdir -p $(CACHE)/samples
	$(NODEMCU-COMMAND) upload $<
	touch $@

$(CACHE)/www/%.upload: www/%
	mkdir -p $(CACHE)/www
	$(NODEMCU-COMMAND) upload $<
	touch $@

$(CACHE)/%.upload: %.lua
	mkdir -p $(CACHE)
	$(NODEMCU-COMMAND) upload --compile $<
	touch $@

.PHONY: clean-cache
clean-cache:
	rm -rf $(CACHE)/

.PHONY: clean
clean: clean-cache
	$(NODEMCU-COMMAND) file format

.PHONY: list
list:
	$(NODEMCU-COMMAND) file list

.PHONY: restart
restart:
	$(NODEMCU-COMMAND) node restart

.PHONY: upload
upload: $(LUA_CACHE) $(AUDIO_CACHE) $(WWW_CACHE)

.PHONY: flash
flash: clean-cache
	# Erase flash to avoid inconsistent state:
	esptool.py --port $(PORT) erase_flash
	# Upload firmware
	esptool.py --port $(PORT) write_flash -fm dio 0x00000 nodemcu_float_master_20191117-0953.bin


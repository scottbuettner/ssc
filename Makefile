MODNAME = Stupid Strings Changer
BUILDDIR = build/$(MODNAME)
EXTRADIRS = "saves/SSC"

all: copy prodzip

copy:
	mkdir -p "$(BUILDDIR)"
	cd "build" && mkdir -p $(EXTRADIRS)
	cp -r -t "$(BUILDDIR)" lib mod.txt *lua *.json LICENSE.txt

# regular zipping
# 2.59 compression ratio
# use if you are a sad human being who does not have p7zip installed
zip:
	cd "build" && zip -r "$(MODNAME).zip" "$(MODNAME)" $(EXTRADIRS)

# production zipping, much more powerful compression
# 2.85 compression ratio :D
prodzip:
	cd "build" && 7z -mx=9 -mm=BZip2 a "$(MODNAME).zip" "$(MODNAME)" $(EXTRADIRS)

clean:
	rm -r "build"

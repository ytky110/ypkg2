TARGET = bin/ypkg2
SRCS   = src/main.sh src/utils.sh src/op/*.sh

$(TARGET): $(SRCS)
	mkdir -p bin
	cat $^ > $@
	echo 'main "$$@"' >> $@
	chmod +x $@

.PHONY: clean

clean:
	rm -fr bin/
	rm -fr pkg/
	.ypkg2/CLEANPKG

# For yports

.PHONY: installpkg2 buildpkg2

installpkg2: buildpkg2
	ypkg2 install pkg/*

buildpkg2: $(TARGET)
	mkdir -p pkg
	.ypkg2/MAKEPKG

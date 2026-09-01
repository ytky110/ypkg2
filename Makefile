TARGET = bin/ypkg2
SRCS   = src/*.sh src/op/*.sh

$(TARGET): $(SRCS)
	mkdir -p bin
	cat $^ > $@
	echo 'main "$$@"' >> $@
	chmod +x $@

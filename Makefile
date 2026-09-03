TARGET = bin/ypkg2
SRCS   = src/main.sh src/utils.sh src/op/*.sh

$(TARGET): $(SRCS)
	mkdir -p bin
	cat $^ > $@
	echo 'main "$$@"' >> $@
	chmod +x $@

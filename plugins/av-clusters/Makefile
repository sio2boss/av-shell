.PHONY: darwin linux all

darwin: Darwin
Darwin:
	cd cmd/switch && GOOS=darwin GOARCH=amd64 go build -v -o  ../../bin/switch .

linux:Linux
Linux:
	cd cmd/switch && GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static"' -v -o ../../bin/switch .

all:
	make `uname -s`
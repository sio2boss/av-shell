.PHONY: all

all:
	cd cmd/inquirer_menu && go build -o ../../bin/inquirer_menu .
	cd cmd/inquirer_multiselect && go build -o ../../bin/inquirer_multiselect .
	cd cmd/inquirer_text && go build -o ../../bin/inquirer_text .

linux:
	cd cmd/inquirer_menu && GOOS=linux GOARCH=amd64 go build -o ../../bin/inquirer_menu .
	cd cmd/inquirer_multiselect && GOOS=linux GOARCH=amd64 go build -o ../../bin/inquirer_multiselect .
	cd cmd/inquirer_text && GOOS=linux GOARCH=amd64 go build -o ../../bin/inquirer_text .
	
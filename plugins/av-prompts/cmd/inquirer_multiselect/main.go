package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"github.com/manifoldco/promptui"
)

var usage = `
Usage:
	inquirer_multiselect [-h] <variable> <option1> [<option2> ...]
`


func main() {

	if os.Args[1] == "-h" {
		fmt.Println("Selection of options via menu")
		os.Exit(0)
	}

	if len(os.Args) < 3 {
		fmt.Println(usage)
		log.Fatal()
	}

	variable := os.Args[1]
	items := os.Args[2:]
	index := -1
	var result string
	var err error

	for index < 0 {
		prompt := promptui.SelectWithAdd{
			Label:    "Select the ones you want",
			Items:    items,
		}

		index, result, err = prompt.Run()

		if index == -1 {
			items = append(items, result)
		}
	}

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		return
	}

	cmd := exec.Command("setpv", variable, result)
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}

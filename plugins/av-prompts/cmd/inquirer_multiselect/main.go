package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"

	"github.com/spaceweasel/promptui"
)

var usage = `
Usage:
	inquirer_multiselect [-h] <variable> <option1> [<option2> ...]
`

func main() {

	if os.Args[1] == "-h" {
		fmt.Println("Selection of multiple options via menu")
		os.Exit(0)
	}

	if len(os.Args) < 3 {
		fmt.Println(usage)
		log.Fatal()
	}

	variable := os.Args[1]
	items := os.Args[2:]
	var selected []int
	var result string
	var err error

	templates := &promptui.MultiSelectTemplates{
		Label:    `{{"Which do you want? "| bold}}`,
		Active:   ` ➜ {{ . | cyan | bold }}`,
		Inactive: `   {{ . | cyan }}`,
		Selected: ` ✔ {{ . | cyan | bold }}`,
	}

	prompt := promptui.MultiSelect{
		Label:     "Select the ones you want",
		Items:     items,
		Templates: templates,
	}

	selected, err = prompt.Run()

	for _, index := range selected {
		if index != -1 {
			result = result + " " + items[index]
		}
	}

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		return
	}

	if result == "None" {
		result = ""
	}

	cmd := exec.Command("setpv", variable, result)
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}

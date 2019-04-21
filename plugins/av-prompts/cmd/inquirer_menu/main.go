package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/manifoldco/promptui"
)

var usage = `
Usage:
	inquirer_menu [-h] <variable> <option1> [<option2> ...]
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
	rawitems := os.Args[2:]

	items := []string{}
	temp := ""
	for _, a := range rawitems {
		if a[len(a)-1] == '"' && (len(temp) > 0) {
			temp += " " + a
			items = append(items, strings.Replace(temp, "\"", "", -1))
			temp = ""
		} else if ((a[0] == '"') && (a[len(a)-1] != '"')) {
			temp += a
		} else if len(temp) > 0 {
			temp += " " + a
		} else {
			items = append(items, strings.Replace(a, "\"", "", -1))
		}
	}

	// The Active and Selected templates set a small pepper icon next to the name colored and the heat unit for the
	// active template. The details template is show at the bottom of the select's list and displays the full info
	// for that pepper in a multi-line template.
	templates := &promptui.SelectTemplates{
		Label:    "{{\"Which do you want? \"| bold}}",
		Active:   "{{\"❯\" | cyan }} {{ . | cyan | underline}}",
		Inactive: "  {{ . | faint }}",
		Selected: " {{\"✔\" | green }} {{\"Which do you want?\"| bold}} › {{ . }}",
	}

	// A searcher function is implemented which enabled the search mode for the select. The function follows
	// the required searcher signature and finds any pepper whose name contains the searched string.
	searcher := func(input string, index int) bool {
		i := items[index]
		name := strings.Replace(strings.ToLower(i), " ", "", -1)
		input = strings.Replace(strings.ToLower(input), " ", "", -1)
		return strings.Contains(name, input)
	}

	prompt := promptui.Select{
		Label:     "Which do you want",
		Items:     items,
		Templates: templates,
		Size:      12,
		Searcher:  searcher,
	}

	_, result, err := prompt.Run()
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

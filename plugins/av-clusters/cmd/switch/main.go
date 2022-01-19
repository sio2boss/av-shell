package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/docopt/docopt-go"
	"github.com/manifoldco/promptui"
)

// exists returns whether the given file or directory exists
func exists(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}

func FindDirectories(root string) ([]string, error) {
	var dirs []string

	fileInfo, err := ioutil.ReadDir(root)
	if err != nil {
		return dirs, err
	}

	for _, info := range fileInfo {
		if info.IsDir() {
			dirs = append(dirs, info.Name())
		}
	}
	return dirs, err
}

type context struct {
	Account string
	Env     string
	Cluster string
}

func main() {
	// config stuff
	usage := `av-shell switch command

Usage:
  switch
  switch --env=<env> --account=<env>
  switch -h | --help
  switch --version

Options:
  --account=<env> Set the selected account manually
  --env=<env>     Set the environment manually
  -h --help       Show this screen.
  --version       Show version.`

	osargs := os.Args[1:]
	arguments, _ := docopt.ParseArgs(usage, osargs, "1.0")

	var config struct {
		environment string `docopt:"--env"`
		account     string `docopt:"--account"`
	}

	arguments.Bind(&config)

	// Find cluster directory
	contents, err := ioutil.ReadFile(".av/config/vars/clusterdir")
	if err != nil {
		log.Fatalf("Unable to read clusterdir persistant variable\n%v", err)
	}
	var clusterdir = string(contents)

	// Walk through clusters
	accounts, err := FindDirectories(clusterdir)
	if err != nil {
		log.Fatalf("Unable to find clusterdir on disk at: %s\n", clusterdir)
	}

	// Walk through accounts
	contexts := []context{}
	for _, account := range accounts {

		// Walk through environments
		envs, _ := FindDirectories(clusterdir + "/" + account)
		for _, env := range envs {

			// Walk through clusters
			clusters, _ := FindDirectories(clusterdir + "/" + account + "/" + env)
			for _, cluster := range clusters {
				contexts = append(contexts, context{
					Account: account,
					Env:     env,
					Cluster: cluster,
				})
			}
		}
	}

	// Prompt
	templates := &promptui.SelectTemplates{
		Label:    "{{ . }}?",
		Active:   "▸ {{ .Account | cyan }} \t> {{ .Env | cyan }} \t> {{ .Cluster | cyan }}",
		Inactive: "  {{ .Account | faint }} \t> {{ .Env | faint }} \t> {{ .Cluster | faint }}",
		Selected: "▸ {{ .Account | cyan }} > {{ .Env | cyan }} > {{ .Cluster | cyan }}",
		Details:  "",
	}

	// TODO provide some details on the selected
	// `--------- Contexts ----------
	// {{ "Account:" | faint }}	{{ .Account }}
	// {{ "Environment:" | faint }}	{{ .Env }}`,

	searcher := func(input string, index int) bool {
		context := contexts[index]
		name := strings.Replace(strings.ToLower(context.Env), " ", "", -1)
		input = strings.Replace(strings.ToLower(input), " ", "", -1)
		return strings.Contains(name, input)
	}

	prompt := promptui.Select{
		Label:     "Which context would you like to switch to",
		Items:     contexts,
		Templates: templates,
		Size:      len(contexts),
		Searcher:  searcher,
	}

	selected, _, err := prompt.Run()

	if err != nil {
		fmt.Printf("Prompt failed %v\n", err)
		return
	}

	// Set pvs

	// Set account
	cmd := exec.Command("setpv", "account", contexts[selected].Account)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'account'\n")
	}
	fmt.Println(" - Updated 'account' variable:" + contexts[selected].Account)

	// Set environment
	cmd = exec.Command("setpv", "environment", contexts[selected].Env)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'environment'\n")
	}
	fmt.Println(" - Updated 'environment' variable:" + contexts[selected].Env)

	// Set cluster
	cmd = exec.Command("setpv", "cluster", contexts[selected].Cluster)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'cluster'\n")
	}
	fmt.Println(" - Updated 'cluster' variable:" + contexts[selected].Cluster)

	// Symlink .env if available
	dest, err := os.Readlink(".env")
	if exists(".env") || (dest != "" && exists(dest) == false) {
		fmt.Println(" - Removing existing .env")
		os.Remove(".env")
	}
	err = os.Symlink(".env."+contexts[selected].Env, ".env")
	if err != nil {
		log.Fatalf("Unable to update .env symlnk\n%v", err)
	}
	fmt.Println(" - Symlinked .env to selected environment")

	// Run persistant variable updates based on selection
	variables := clusterdir + "/" + contexts[selected].Account + "/" + contexts[selected].Env + "/" + contexts[selected].Cluster + "/inventory/variables.sh"
	if exists(variables) {
		os.Chmod(variables, 0700)
		cmd := exec.Command(variables)
		if err := cmd.Run(); err != nil {
			log.Fatalf("Unable to set persistant variable based on inventory...\n%v", err)
		}
		fmt.Println(" - Updated variables as defined in 'inventory/variables.sh'")
	}

	contextLabel := contexts[selected].Account + " > " + contexts[selected].Env + " > " + contexts[selected].Cluster
	fmt.Println()
	fmt.Println("Using", contextLabel, "as environment, you will need to restart your shell")

}

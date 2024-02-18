#!/usr/bin/env gorun

// go.mod >>>
// module av-clusters
// go 1.15
// require (
// 	github.com/docopt/docopt-go v0.0.0-20180111231733-ee0de3bc6815
// 	gopkg.in/yaml.v2 v2.4.0
// 	github.com/manifoldco/promptui v0.9.0
// )
// <<< go.mod
//
// go.sum >>>
// github.com/chzyer/logex v1.1.10/go.mod h1:+Ywpsq7O8HXn0nuIou7OrIPyXbp3wmkHB+jjWRnGsAI=
// github.com/chzyer/readline v0.0.0-20180603132655-2972be24d48e h1:fY5BOSpyZCqRo5OhCuC+XN+r/bBCmeuuJtjz+bCNIf8=
// github.com/chzyer/readline v0.0.0-20180603132655-2972be24d48e/go.mod h1:nSuG5e5PlCu98SY8svDHJxuZscDgtXS6KTTbou5AhLI=
// github.com/chzyer/test v0.0.0-20180213035817-a1ea475d72b1/go.mod h1:Q3SI9o4m/ZMnBNeIyt5eFwwo7qiLfzFZmjNmxjkiQlU=
// github.com/docopt/docopt-go v0.0.0-20180111231733-ee0de3bc6815 h1:bWDMxwH3px2JBh6AyO7hdCn/PkvCZXii8TGj7sbtEbQ=
// github.com/docopt/docopt-go v0.0.0-20180111231733-ee0de3bc6815/go.mod h1:WwZ+bS3ebgob9U8Nd0kOddGdZWjyMGR8Wziv+TBNwSE=
// github.com/manifoldco/promptui v0.9.0 h1:3V4HzJk1TtXW1MTZMP7mdlwbBpIinw3HztaIlYthEiA=
// github.com/manifoldco/promptui v0.9.0/go.mod h1:ka04sppxSGFAtxX0qhlYQjISsg9mR4GWtQEhdbn6Pgg=
// golang.org/x/sys v0.0.0-20181122145206-62eef0e2fa9b h1:MQE+LT/ABUuuvEZ+YQAMSXindAdUh7slEmAkup74op4=
// golang.org/x/sys v0.0.0-20181122145206-62eef0e2fa9b/go.mod h1:STP8DvDyc/dI5b8T5hshtkjS+E42TnysNCUPdjciGhY=
// gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405 h1:yhCVgyC4o1eVCa2tZl7eS0r+SDo693bJlVdllGtEeKM=
// gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod h1:Co6ibVJAznAaIkqp8huTwlJQCZ016jof/cbN4VW5Yz0=
// gopkg.in/yaml.v2 v2.4.0 h1:D8xgwECY7CYvx+Y2n4sBz93Jn9JRvxdiyyo8CTfuKaY=
// gopkg.in/yaml.v2 v2.4.0/go.mod h1:RDklbk79AGWmwhnvt/jBztapEOGDOx6ZbXqjP6csGnQ=
// <<< go.sum

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
	Account string `docopt:"--account"`
	Env     string `docopt:"--env"`
	Cluster string `docopt:"--cluster"`
}

func main() {
	// config stuff
	usage := `av-shell switch command

Usage:
  switch
  switch --env=<env> --account=<account> --cluster=<cluster>
  switch -h | --help
  switch --version

Options:
  --account=<account>  Set the selected account manually.
  --env=<env>          Set the environment manually.
  --cluster=<cluster>  Set the cluster manually.
  -h --help            Show this screen.
  --version            Show version.`

	if os.Getenv("AV_SINGLE_LINE_HELP") != "" {
		fmt.Println("Switch between cloud deployment environments")
		os.Exit(0)
	}

	osargs := os.Args[1:]
	arguments, _ := docopt.ParseArgs(usage, osargs, "1.0")

	var config context
	arguments.Bind(&config)

	// Find cluster directory
	contents, err := ioutil.ReadFile(".av/config/vars/clusterdir")
	if err != nil {
		log.Fatalf("Unable to read clusterdir persistant variable\n%v", err)
	}
	var clusterdir = string(contents)

	var sel_ctx context
	if config.Account != "" && config.Env != "" && config.Cluster != "" {
		sel_ctx = config
	} else {

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
		sel_ctx = contexts[selected]
	}

	// Set pvs
	// Set account
	cmd := exec.Command("setpv", "account", sel_ctx.Account)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'account'\n")
	}
	fmt.Println(" - Updated 'account' variable: " + sel_ctx.Account)

	// Set environment
	cmd = exec.Command("setpv", "environment", sel_ctx.Env)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'environment'\n")
	}
	fmt.Println(" - Updated 'environment' variable: " + sel_ctx.Env)

	// Set cluster
	cmd = exec.Command("setpv", "cluster", sel_ctx.Cluster)
	if err := cmd.Run(); err != nil {
		log.Fatalf("Unable to set persistant variable: 'cluster'\n")
	}
	fmt.Println(" - Updated 'cluster' variable: " + sel_ctx.Cluster)

	// Symlink .env if available
	dest, err := os.Readlink(".env")
	if exists(".env") || (dest != "" && exists(dest) == false) {
		fmt.Println(" - Removing existing .env")
		os.Remove(".env")
	}
	err = os.Symlink(".env."+sel_ctx.Env, ".env")
	if err != nil {
		log.Fatalf("Unable to update .env symlnk\n%v", err)
	}
	fmt.Println(" - Symlinked .env to selected environment")

	// Run persistant variable updates based on selection
	variables := clusterdir + "/" + sel_ctx.Account + "/" + sel_ctx.Env + "/" + sel_ctx.Cluster + "/inventory/variables.sh"
	if exists(variables) {
		os.Chmod(variables, 0700)
		cmd := exec.Command(variables)
		if err := cmd.Run(); err != nil {
			log.Fatalf("Unable to set persistant variable based on inventory...\n%v", err)
		}
		fmt.Println(" - Updated variables as defined in 'inventory/variables.sh'")
	}

	fmt.Println()
	fmt.Println("\033[33mRun 'refresh' for shell to pickup all changes")
	fmt.Println()

}

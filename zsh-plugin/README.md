# av-shell plugin

When switching (cwd) to a project directory that has av-shell enabled, the environment will be automounted.  This means that by just using `cd` your project specific commands will be available in the zsh shell.  Upon switching out of the directory, the project specific commands are unmounted automatically.
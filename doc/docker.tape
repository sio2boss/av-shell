Output docker.gif

Set Width 1600
Set Height 800
Set TypingSpeed 0.2
Set WindowBar Colorful

Type av
Sleep 500ms
Enter 1
Sleep 1000ms

Type choose
Sleep 500ms
Enter 1
Sleep 2000ms
Down 1
Sleep 500ms
Up 1
Sleep 500ms
Down 1
Sleep 500ms
Enter 1
Sleep 1000ms

Type build 
Sleep 500ms
Enter 1
Sleep 3000ms

Type run ## pulls cli options from containers/<name>/Runfile
Sleep 2000ms
Enter 1
Sleep 1000ms

Type ps
Sleep 500ms
Enter 1
Sleep 2000ms

Type "shell ## uses last container start"
Enter 3
Sleep 1000ms
Type "## In the running container now"
Enter 1
Sleep 1000ms
Type ls
Sleep 500ms
Enter 1
Sleep 1000ms
Type "uname -a"
Sleep 500ms
Enter 1
Sleep 1000ms
Type "## Pop back out of container"
Enter 1
Sleep 1000ms
Type exit
Enter 3
Sleep 2000ms

Type "stop ## uses same container hash"
Enter 1
Sleep 1000ms

Type ps
Sleep 500ms
Enter 1
Sleep 2000ms

Type "# Makes for easy repeated build/run cycles, try it out!"
Enter 1
Sleep 3000ms
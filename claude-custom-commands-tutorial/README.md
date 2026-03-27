# Custom Commands Tutorial


### How to directly import these changes into you claude?
Since this tutorial is just about custom commands we can move whole commands folder from here to either local or global claude code settings (depending upon preference)

Command to move this to local preference
```
mkdir -p <repo-link>/.claude
mv -r commands/* <repo-link>/.claude/
```

Command to move this to global preference
```
mv -r commands/* ~/.claude/
```

If you want to move any single file from this commands dir, instead of * use the file name in the above mentioned command.
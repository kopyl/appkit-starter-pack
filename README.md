### Automate project creation with create-macos-app.sh


create-macos-app.sh bash script automates AppKit project creation with opinionated defaults:
1. Minimum macOS version: 12.0
2. "Debug executable" is disabled when a project is created

To create a project, simply run `sh create-macos-app.sh 'my app'` with the name of your app (instead of 'my app')
When a project is created for the first time, it's going to ask you for your organization identifier, which you can usually find when you press "command + Shift + N" to create a new project, select project type, hit "Next" and see the project's options:
<img width="738" height="530" alt="image" src="https://github.com/user-attachments/assets/fca6d456-5277-414b-b7d0-01480e93662c" />


# RunScriptPlugin

SwiftPackage Plugin for executing arbitrary ShellScript.

## Feature
- BuildToolPlugin: RunScriptPlugin
- CommandPlugin: RunScriptCommandPlugin
- XcodeBuildToolPlugin: RunScriptPlugin
- XcodeCommandPlugin: RunScriptCommandPlugin

## Usage
Place the file named `runscript.yml`(or `.runscript.yml`) in the root of the project.
Write the shell script you want to run in this file.

The format is as follows.

```yaml
prebuild: # prebuild Command
  - name: "Hello"
    script: "echo Hello" # Write scripts directly
  - name: "Show current path"
    script: "pwd"
  - name: "Write file"
    script: "echo Hello >> test.txt"

  - name: "SwiftLint"
    launchPath: "/bin/bash" # bash, zsh, etc. can be specified
    script: "swiftlint lint --fix"

  - name: "SwiftLint" # Another way to write ↑↑
    launchPath: "/usr/local/bin/swiftlint"
    arguments:
      - "lint"
      - "--fix"

  - name: "Update schema"
    file: "update_schema.sh" # Execute .sh file

build: # build Command
   - name: "Hello"
     script: "echo Hello"

command: # Command Plugin
  - name: "Hello from Command"
    script: "echo 'Hello from Command'"

all: # run in `prebuild`, `build`...
   - name: "Hello(all)"
     script: "echo Hello(all)"
```

> [!NOTE]
> Due to a limitation of Xcode, you may get a permission error when trying to write a file.
>
> If CommandPlugin is run from the shell, it is possible to work around this by disabling the sandbox using the `--disable-sandbox` option.
> ```sh
> swift package plugin --allow-writing-to-package-directory --disable-sandbox run-script
> ```
>
>　If you want to avoid the use of the BuildToolPlugin/CommandPlugin via Xcode, you can disable the use of the sandbox by configuring the following settings.
> ```sh
> defaults write com.apple.dt.Xcode IDEPackageSupportDisablePluginExecutionSandbox -bool YES
> ```

## Example
- SwiftLint
You can run Lint in SPM without using the SwiftLint plugin.
```yaml
- name: "SwiftLint"
  script: "swiftlint lint"
```

- Build Log
```yaml
- name: "Build Log"
  script: "echo \"[$(date)] Build >> build.log\""
```

- Theos(Orion) install
You can install the Tweak from the Build button in SPM.
```yaml
- name: "Theos make package and install"
  script: "make do"
```
- SwiftFormat
```yaml
- name: "SwiftFormat"
  script: "swiftformat ."
```

- SwiftGen
```yaml
- name: "SwiftGen"
  script: "swiftgen config run"
```

# sdftools.nvim

## Neovim plugin to provide a user interface to the Netsuite SDF CLI

![sdfdemo](https://github.com/rtanner1231/sdftools.nvim/assets/142627958/caff442c-0b73-4a4f-8a29-35d5507d7664)

# Main Features
- Neovim commands to support uploading script files and deploying a SDF project
  - File upload resolves typescript files
- UI for selecting objects to import

# Requirements
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [SuiteCloud CLI for Node JS](https://www.npmjs.com/package/@oracle/suitecloud-cli)
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) (Optional)

# Installation
Install with your preferred package manager.  Optionally call a setup function to override default options.

## [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    'rtanner1231/sdftools.nvim',
    dependencies = {
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim"
    },
    opts={
        -- override default options
    }
}
```

# Configuration Options

## Defaults

```lua
{
    typescriptPath='/TypeScripts/',
    toggleTerm=false,
    terminalSplitDirection='Horizontal',
    sourceDir='src',
    runTSBuildOnFileUpload=true,
    typescriptBuildCommand='npm run build'
}
```

- **typescriptPath** (*default: '/TypeScripts/'*) - Directory which holds the typescript source files.  This should be the directory which builds into the SuiteScripts directory.  Only used for typescript projects
- **toggleTerm** (*default: false*) - Indicates whether to use the toggle term plugin for displaying terminal output.  If false, a terminal buffer will be opened.  The [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) plugin is required if set to true.
- **terminalSplitDirection** (*default: 'Horizontal'*) - The type of split to use when creating a terminal buffer.  Valid values are "Horizontal" and "Vertical".  Ignored if **toggleTerm** option is true.
- **sourceDir** (*default: 'src'*) - The path to the directory containing the deployable source files.  This should be the directory which contains the deploy.xml and manifest.xml files.
- **runTSBuildOnFileUpload** (*default: true*) - Should a build command be run before uploading typescript files.  If true, the value in the **typescriptBuildCommand** option will be run immediatly before file upload for Typescript files.
- **typescriptBuildCommand** (*default: 'npm run build'*) - The build to run to build the Typescript files.  Ignored if the **runTSBuildOnFileUpload** option is false

# Commands
This plugin supports the below commands.  All commands are accessible from the options menu.
- ```:SDF``` - Show the options menu
- ```:SDF Deploy``` - Deploy the current project (Uses ```suitecloud project:deploy```)
- ```:SDF DeployCurrentFolder``` - Uploads files in the current directory.  This does not recursively upload files in subdirectories.  (Uses ```suitecloud file:upload```)
- ```:SDF DeployCurrentFile``` - Uploads the file in the currently opened buffer.  (Uses ```suitecloud file:upload```)
- ```:SDF GitDeployUnstaged``` - Runs the git command ```git diff --name-only``` to get the unstaged files and uploads them.  Untracked files are not uploaded.  (Uses ```suitecloud file:upload```)
- ```:SDF GitDeployStaged``` - Runs the git command ```git diff --name-only --staged``` to get the staged files and uploads them.  (Uses ```suitecloud file:upload```)
- ```:SDF SelectAccount``` - Show an options picked to select the Netsuite account to use.  Either press the number next to the account or place your cursor over the line with the account and press enter to select.  Press q to cancel.  (Uses ```suitecloud account:setup```)
- ```:SDF ImportObjects``` - Show a dialog to pick objects to import into the project.  (Uses ```suitecloud object:list``` and ```suitecloud object:import```)

# Usage

## Uploading files

This plugin provides four commands for uploading individual files:
- ```:SDF DeployCurrentFolder```
- ```:SDF DeployCurrentFile```
- ```:SDF GitDeployUnstaged```
- ```:SDF GitDeployStaged```

Running one of these commands will show a confirmation dialog.  The dialog shows the account the files will be uploaded to on the first line.  The remaining lines in the dialog show the list of files which will be uploaded.  Press y or enter to accept.  Press n or esc to cancel.
![image](https://github.com/rtanner1231/sdftools.nvim/assets/142627958/38953c78-40c4-488e-a1f4-178b9918e568)


## Uploading typescript files

Running the file upload commands will upload the corresponding javascript file if it is run on a typescript file.  For this to work, the directory which holds the typescript files and will be built into the SuiteScripts folder needs to be set up in the **typescriptPath** option in the config options.  For example, if your project has this structure:
```
├── Root
│   ├── dist
│   │   ├── FileCabinet
│   │   │   ├── SuiteScripts
│   │   │   │   ├── <{compiled javascript files}>
│   │   │   ├── Objects
│   │   │   ├── deploy.xml
│   │   │   ├── manifest.xml
│   ├── TypeScripts
│   │   ├── <{source typescript files}>
```
The **typescriptPath** option should have the value of "/TypeScripts/" (This is the default value)

If the Typescript files should be built before uploading, set the **runTSBuildOnFileUpload** option to true (the default value).  If this is set, the command in the **typescriptBuildCommand** (default ```npm run build```) option will be run before uploading files.  This command will only be run for file uploads, not the Deploy command.

---
name: init-maestro
description: Initialize Maestro config by copying agents, skills (except init-maestro), and assets to .devin folder
argument-hint: ""
allowed-tools:
  - ask_user_question
permissions:
  allow:
    - read
    - exec
    - write
  deny: []
---

# Initialize Maestro Config

Initializes the Maestro configuration by copying the agents, skills (excluding init-maestro), and assets folders from Maestro to a new .devin folder in the current workspace

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace (you should only modify files in this folder)

## Core Workflow

1. Check if `.devin` folder exists in the current workspace
2. If `.devin` exists, ask user permission to delete it:
   - Use `ask_user_question` with the question: "The .devin folder already exists in the workspace. Do you want to delete it and reinitialize?"
   - Options: "Yes, delete and reinitialize", "No, abort"
   - If user chooses "No, abort", output an error message and abort the initialization
3. If user confirms deletion (or .devin doesn't exist), proceed:
   - If `.devin` exists, delete it
4. Get the Maestro source folder path:
   - First, check if `path.txt` exists beside the skill ({{skill_dir}}/path.txt)
   - If `path.txt` exists, read the config path from it
   - Otherwise, use {{skill_dir}}/../../ as the config path
5. Create a new `.devin` folder in the current workspace
6. Copy the following folders from the source folder to `.devin`:
   - `agents/`
   - `skills/` (copy all skills except the `init-maestro` skill folder itself)
   - `assets/`
7. Output the success message with the paths
8. Display the `.devin` folder tree structure using `tree` command (or `Get-ChildItem -Recurse` if tree is not available)

## Expected Output

**Success:**
```
Initialized Maestro config:
- .devin folder: {workspace_dir}/.devin/
- Source folder: {source_path}

Folder tree:
{tree structure output}
```

**Aborted by user:**
```
Initialization aborted by user. The existing .devin folder was preserved.
```

## Error Handling

- If the source folder path cannot be determined or folders cannot be copied, output an error message indicating the specific issue.
- If the user chooses not to delete the existing .devin folder, output the abort message and exit without making changes.

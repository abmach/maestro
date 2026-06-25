---
name: init-maestro
description: Initialize Maestro config by copying skills (except init-maestro) and assets to .agents folder
allowed-tools:
  - ask_user_question
  - read
  - exec
  - write
permissions:
  allow:
    - Write(./.agents/**/*)
    - Exec(./)
---

# Initialize Maestro Config

Initializes the Maestro configuration by extracting the Maestro bundle (skills, assets) from bundle.zip and copying them to a new `.agents` folder in `{{workspace_dir}}`

## Pre-flight

- Working folder: `{{workspace_dir}}` - the root of the project/workspace
- Target folders: `{{workspace_dir}}/.agents/` (you should only modify files in this folder)
- Required input: None (uses bundle.zip from skill directory)

## Validation

- If bundle.zip doesn't exist in skill directory, abort with error

## Core Workflow

1. Check if `.agents` folder exists in `{{workspace_dir}}`
2. If `.agents` exists, ask user permission to delete it:
   - Use `ask_user_question` with the question: "The `.agents` folder already exists in `{{workspace_dir}}`. Do you want to delete it and reinitialize?"
   - Options: "Yes, delete and reinitialize", "No, abort"
   - If user chooses "No, abort", output an error message and abort the initialization
3. If user confirms deletion (or `.agents` doesn't exist), proceed:
   - If `.agents` exists, delete it
4. Locate bundle.zip in the skill directory (`{{skill_dir}}/bundle.zip`)
5. Create a new `.agents` folder in `{{workspace_dir}}`
6. Extract bundle.zip directly to `.agents`:
   - Use appropriate command based on OS (PowerShell `Expand-Archive` on Windows, `unzip` on Linux/Mac)
7. Output the success message with the paths
8. Display the `.agents` folder tree structure using `tree` command (or `Get-ChildItem -Recurse` if tree is not available)

## Expected Output

**Success:**
```
Initialized Maestro config:
- .agents folder: {{workspace_dir}}/.agents/

Folder tree:
{tree structure output}
```

**Aborted by user:**
```
Initialization aborted by user. The existing .agents folder was preserved.
```

## Error Handling

- If bundle.zip doesn't exist in the skill directory, output an error message indicating the bundle is missing.
- If bundle.zip cannot be extracted, output an error message indicating the extraction failed.
- If folders cannot be copied from the extracted bundle, output an error message indicating the copy operation failed.
- If the user chooses not to delete the existing `.agents` folder, output the abort message and exit without making changes.

---
name: skilled_agent
description: Subagent that can run skills.
permissions:
  allow:
    - read
    - find_file_by_name
    - grep
    - write
    - edit
    - skill
  ask:
    - webfetch
  deny:
    - run_subagent
---

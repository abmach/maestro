---
name: test
description: Test skill
subagent: true
agent: skilled_agent
permissions:
  allow:
    - read
    - find_file_by_name
    - grep
    - skill
    - web_search
  deny:
    - write
    - exec
---

# Test Skills

Output the following:
- Working folder: `{{workspace_dir}}`
- `Assets` folder (invoke `@skills:get-assets-path` skill to find it)

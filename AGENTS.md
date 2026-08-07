## general

1. must read skills and subskills in full, no truncation.
2. NEVER run scripts inside the skills directory themselves or one of its subdirs, 
always run from initial current working directory(<original_pwd>).


## Skill / Tool Execution Discipline

When a skill provides an inline bash command (or any shell snippet), execute it
**exactly as written**, with these rules:

1. Substitute placeholder tokens (`<device>`, `<path>`, `${VAR}`, etc.) with the
   value the user supplied. Do not invent values.
2. **Do NOT swap tools.** `rg` stays `rg`, not `grep`. `fd` stays `fd`, not `find`.
   `jq` stays `jq`, not python json parsing.
3. **Do NOT add, remove, or reorder flags.** If the command says `-i`, run `-i`.
4. **Do NOT "optimize" or "improve" the command.** No shortcuts, no "you can also
   use...". Just run what's there.
5. If the command looks wrong or could be done better, run it anyway and then
   mention the suggestion in chat — never silently rewrite it.

The skill author chose that command deliberately. Treat the script block as
**literal text**, not as a hint about your intent.

## Task Tracking & Progress
- **Mandatory Checklist**: Always start every task by generating a detailed markdown checklist using `- [ ]` for pending steps and `- [x]` for completed steps.
- **Incremental Updates**: Update this checklist dynamically after completing every individual step. Do not skip printing or updating this progress log.
- **Workflow State**: If transitioning between multiple tools, output the updated todo list first so the user can track the pipeline execution.



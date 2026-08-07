#!/usr/bin/env bash
set -x

prompt="$1"

repomix --copy --no-default-patterns -o ../archive.md --style markdown --include "devices/**,${prompt}.text,${prompt}_clean.log" --ignore "**/.zig-cache/**" 

#repomix -o ../archive.md --style markdown --include *.txt,*.md,*.diff
#repomix -o ../examples.md --style markdown --include examples/** --ignore **/target/
#sed -ri "s/\x1B\[[0-9;]*[a-zA-Z]//g" ../archive.md

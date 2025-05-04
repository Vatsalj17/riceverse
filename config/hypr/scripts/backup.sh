#!/bin/bash

COMMIT_MSG="Backup: $(date '+%Y-%m-%d %H:%M:%S')"

git add $HOME || exit 1

# Only commit if there's anything new
if ! git diff --cached --quiet; then
  git commit -m "$COMMIT_MSG"
  git push origin main
fi

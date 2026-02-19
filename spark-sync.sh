#!/bin/bash
# spark-sync: Agent -> spark real-time sync + GitHub auto-push
AGENT_DIR="/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/Agent"
SPARK_DIR="/Users/admin/Documents/spark"
LOG_FILE="$SPARK_DIR/.spark-sync.log"
DEBOUNCE_SEC=30

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

sync_files() {
  log "Syncing Agent -> spark..."
  for dir in .github memory n8n-agent n8n-automation n8n-server Pages Script x-automation; do
    if [ -d "$AGENT_DIR/$dir" ]; then
      mkdir -p "$SPARK_DIR/$dir"
      rsync -aq --timeout=10 \
        --exclude='.obsidian' --exclude='.venv' --exclude='node_modules' \
        --exclude='__pycache__' --exclude='.DS_Store' --exclude='*.zip' \
        "$AGENT_DIR/$dir/" "$SPARK_DIR/$dir/" 2>/dev/null
    fi
  done
  for file in MEMORY.md PROJECT_STATUS.md README.md SOUL.md USER.md supabase-schema.sql; do
    [ -f "$AGENT_DIR/$file" ] && cp "$AGENT_DIR/$file" "$SPARK_DIR/$file" 2>/dev/null
  done
  log "Sync complete"
}

push_to_github() {
  cd "$SPARK_DIR" || return 1
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A
    changed=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    git commit -m "spark auto-sync: ${changed} files ($(date '+%m/%d %H:%M'))" --quiet 2>/dev/null
    if git push origin main --quiet 2>&1; then
      log "Pushed ${changed} files to GitHub"
    else
      log "Push failed - retry next cycle"
    fi
  else
    log "No changes"
  fi
}

trap 'log "spark-sync stopped"; rm -f /tmp/spark-sync.pid; exit 0' INT TERM

if [ -f /tmp/spark-sync.pid ]; then
  old=$(cat /tmp/spark-sync.pid)
  kill -0 "$old" 2>/dev/null && kill "$old" 2>/dev/null
fi
echo $$ > /tmp/spark-sync.pid

echo "spark-sync started | Agent -> spark -> GitHub"
sync_files
push_to_github
log "Watching for changes (${DEBOUNCE_SEC}s debounce)..."

fswatch -o \
  --exclude='\.git' --exclude='\.venv' --exclude='\.DS_Store' \
  --exclude='\.claude' --exclude='\.obsidian' \
  --exclude='node_modules' --exclude='__pycache__' \
  -l "$DEBOUNCE_SEC" "$AGENT_DIR" 2>/dev/null | while read count; do
  log "Detected changes"
  sync_files
  push_to_github
done

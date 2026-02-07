#!/bin/bash
# Claude Code Status Line
# Multi-line display with model, git, context usage, cost, and duration

input=$(cat)

# Extract JSON fields
MODEL=$(echo "$input" | jq -r '.model.display_name')
AGENT=$(echo "$input" | jq -r '.agent.name // ""')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# ANSI color codes
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Cache expensive git operations
CACHE_FILE="/tmp/statusline-git-cache-$(echo "$DIR" | md5sum | cut -d' ' -f1)"
CACHE_MAX_AGE=5  # seconds

cache_is_stale() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 0
    fi
    # Use date and stat in a portable way
    local now=$(date +%s)
    local mtime
    if stat -c %Y "$CACHE_FILE" >/dev/null 2>&1; then
        # Linux
        mtime=$(stat -c %Y "$CACHE_FILE")
    elif stat -f %m "$CACHE_FILE" >/dev/null 2>&1; then
        # macOS
        mtime=$(stat -f %m "$CACHE_FILE")
    else
        # Fallback: always refresh
        return 0
    fi
    local age=$((now - mtime))
    [ "$age" -gt "$CACHE_MAX_AGE" ]
}

# Update git cache if stale
if cache_is_stale; then
    if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
        STAGED=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi

# Read cached git data
IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

# Build first line: Model, agent, directory, git info, lines changed
MODEL_DISPLAY="${CYAN}[${MODEL}]${RESET}"
if [ -n "$AGENT" ]; then
    MODEL_DISPLAY="${MODEL_DISPLAY} ${YELLOW}@${AGENT}${RESET}"
fi

GIT_INFO=""
if [ -n "$BRANCH" ]; then
    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
    GIT_INFO=" | ${GREEN}🌿 ${BRANCH}${RESET} ${GIT_STATUS}"
fi

# Add lines changed
LINES_INFO=""
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
    [ "$LINES_ADDED" -gt 0 ] && LINES_INFO="${GREEN}+${LINES_ADDED}${RESET}"
    [ "$LINES_REMOVED" -gt 0 ] && LINES_INFO="${LINES_INFO}${RED}-${LINES_REMOVED}${RESET}"
    [ -n "$LINES_INFO" ] && LINES_INFO=" ${LINES_INFO}"
fi

printf '%b' "${MODEL_DISPLAY} 📁 ${DIR##*/}${GIT_INFO}${LINES_INFO}\n"

# Build second line: Context bar with color-coding
if [ "$PCT" -ge 90 ]; then
    BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
    BAR_COLOR="$YELLOW"
else
    BAR_COLOR="$GREEN"
fi

# Create progress bar (10 characters wide)
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '█')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

# Format duration
MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

# Format cost
COST_FMT=$(printf '$%.2f' "$COST")

printf '%b' "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️  ${MINS}m ${SECS}s\n"

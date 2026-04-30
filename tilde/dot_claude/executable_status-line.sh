#!/bin/bash
# Claude Code Status Line

input=$(cat)

eval "$(echo "$input" | jq -r '
  @sh "used_pct=\(.context_window.used_percentage // 0)",
  @sh "window_size=\(.context_window.context_window_size // 0)",
  @sh "current_input_tokens=\(.context_window.current_usage.input_tokens // 0)",
  @sh "cache_create_tokens=\(.context_window.current_usage.cache_creation_input_tokens // 0)",
  @sh "cache_read_tokens=\(.context_window.current_usage.cache_read_input_tokens // 0)",
  @sh "model=\(.model.display_name // "")",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "duration_ms=\(.cost.total_duration_ms // 0)",
  @sh "lines_added=\(.cost.total_lines_added // 0)",
  @sh "lines_removed=\(.cost.total_lines_removed // 0)",
  @sh "project_dir=\(.workspace.project_dir // .workspace.current_dir // "")",
  @sh "transcript_path=\(.transcript_path // "")",
  @sh "agent_name=\(.agent.name // "")",
  @sh "effort_level=\(.effort.level // "")",
  @sh "five_hour_pct=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "five_hour_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "seven_day_pct=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "seven_day_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

# --- ANSI colors ---
RST=$'\033[0m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'
MAGENTA=$'\033[35m'
BLUE=$'\033[34m'
CYAN_UL=$'\033[36;4m'
PURPLE=$'\033[35m'

# --- OSC 8 hyperlink helpers ---
LINK_OPEN=$'\033]8;;'
LINK_CLOSE=$'\033\\'

# --- Fallback ---
if [ "${window_size:-0}" -le 0 ] 2>/dev/null; then
  printf '%s\n' "[....................] --% | ?"
  exit 0
fi

# --- Helpers ---
fmt_k() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    awk -v n="$n" 'BEGIN { v = n / 1000000; if (v == int(v)) printf "%dM", v; else printf "%.1fM", v }'
  elif [ "$n" -ge 1000 ]; then
    printf "%sK" "$((n / 1000))"
  else
    printf "%s" "$n"
  fi
}

compact_model() {
  local name="$1"
  name="${name//Claude /}"
  name=$(printf '%s' "$name" | sed -E 's/[[:space:]]*\([0-9.]+[kKmM]?[[:space:]]+context\)//g; s/[[:space:]]+/ /g; s/^ //; s/ $//')
  printf '%s' "${name:-Claude}"
}

usage_color() {
  local pct=$1
  if [ "$pct" -ge 90 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "$pct" -ge 70 ] 2>/dev/null; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"
  fi
}

format_epoch() {
  local epoch="$1" style="$2"
  [ -n "$epoch" ] && [ "$epoch" != "null" ] && [ "$epoch" != "0" ] || return
  case "$style" in
    date) date -d "@$epoch" +"%b %-d, %H:%M" 2>/dev/null || date -r "$epoch" +"%b %-d, %H:%M" 2>/dev/null ;;
    *)    date -d "@$epoch" +"%H:%M" 2>/dev/null || date -r "$epoch" +"%H:%M" 2>/dev/null ;;
  esac
}

render_limit() {
  local label="$1" pct="$2" reset_at="$3" reset_style="$4"
  [ -n "$pct" ] && [ "$pct" != "null" ] || return
  local pct_int color reset_text
  pct_int=$(awk -v pct="$pct" 'BEGIN { printf "%.0f", pct }')
  color=$(usage_color "$pct_int")
  reset_text=$(format_epoch "$reset_at" "$reset_style")
  printf '%b' " ${DIM}|${RST} ${label} ${color}${pct_int}%${RST}"
  [ -n "$reset_text" ] && printf '%b' " ${DIM}@${reset_text}${RST}"
}

render_effort() {
  local level="$1"
  [ -n "$level" ] || return
  case "$level" in
    low)    printf '%b' " ${DIM}|${RST} effort:${DIM}low${RST}" ;;
    medium) printf '%b' " ${DIM}|${RST} effort:${YELLOW}med${RST}" ;;
    high)   printf '%b' " ${DIM}|${RST} effort:${GREEN}high${RST}" ;;
    xhigh)  printf '%b' " ${DIM}|${RST} effort:${PURPLE}xhigh${RST}" ;;
    max)    printf '%b' " ${DIM}|${RST} effort:${RED}max${RST}" ;;
    *)      printf '%b' " ${DIM}|${RST} effort:${level}${RST}" ;;
  esac
}

# --- Git caching (per-project, keyed by dir) ---
dir_hash=$(echo "$project_dir" | md5sum | cut -d' ' -f1)
GIT_CACHE="/tmp/claude-statusline-git-${dir_hash}.cache"
GIT_TTL=5

cache_is_fresh() {
  local file="$1" ttl="$2"
  [ -f "$file" ] || return 1
  local now file_mtime age
  now=$(date +%s)
  if file_mtime=$(stat -c %Y "$file" 2>/dev/null); then
    :
  else
    file_mtime=$(stat -f %m "$file" 2>/dev/null) || return 1
  fi
  age=$((now - file_mtime))
  [ "$age" -lt "$ttl" ]
}

if ! cache_is_fresh "$GIT_CACHE" "$GIT_TTL"; then
  if git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$project_dir" branch --show-current 2>/dev/null)
    staged=$(git -C "$project_dir" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    modified=$(git -C "$project_dir" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    remote=$(git -C "$project_dir" remote get-url origin 2>/dev/null)
    printf '%s\n%s\n%s\n%s\n' "$branch" "$staged" "$modified" "$remote" > "$GIT_CACHE"
  else
    printf '\n0\n0\n\n' > "$GIT_CACHE"
  fi
fi

{
  IFS= read -r git_branch
  IFS= read -r git_staged
  IFS= read -r git_modified
  IFS= read -r git_remote
} < "$GIT_CACHE"

# --- Subscription limits (only when Claude reports them) ---
subscription_seg=""
if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  subscription_seg="$(render_limit "5h" "$five_hour_pct" "$five_hour_reset" "time")$(render_limit "7d" "$seven_day_pct" "$seven_day_reset" "date")"
fi

# --- Plan detection (from transcript) ---
PLAN_CACHE="/tmp/claude-statusline-plan-${dir_hash}.cache"
PLAN_TTL=10
plan_name=""

if cache_is_fresh "$PLAN_CACHE" "$PLAN_TTL"; then
  read -r cached_transcript cached_plan < "$PLAN_CACHE" 2>/dev/null
  [ "$cached_transcript" = "$transcript_path" ] && plan_name="$cached_plan"
fi

if [ -z "$plan_name" ] && [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  match=$(grep -o '\.claude/plans/[^"]*\.md' "$transcript_path" 2>/dev/null | tail -1)
  [ -n "$match" ] && plan_name=$(basename "$match" .md)
  echo "$transcript_path $plan_name" > "$PLAN_CACHE"
fi

# --- Convert git remote to GitHub URL ---
github_url=""
if [ -n "$git_remote" ]; then
  if [[ "$git_remote" =~ ^git@([^:]+):(.+)\.git$ ]]; then
    github_url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  elif [[ "$git_remote" =~ ^git@([^:]+):(.+)$ ]]; then
    github_url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  elif [[ "$git_remote" =~ ^https?:// ]]; then
    github_url="${git_remote%.git}"
  fi
fi

# --- Line 1: Model, dir, git, plan ---
model_label=$(compact_model "$model")
line1="${CYAN}[${model_label}]${RST}"

if [ -z "$effort_level" ]; then
  effort_level="${CLAUDE_CODE_EFFORT_LEVEL:-}"
fi
if [ -z "$effort_level" ] && [ -f "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" ]; then
  effort_level=$(jq -r '.effortLevel // empty' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" 2>/dev/null)
fi

[ -n "$agent_name" ] && line1="${line1} ${MAGENTA}@${agent_name}${RST}"

[ -n "$project_dir" ] && line1="${line1} ${project_dir##*/}"

if [ -n "$git_branch" ]; then
  line1="${line1} (${GREEN}${git_branch}${RST}"
  [ "${git_staged:-0}" -gt 0 ] && line1="${line1} ${GREEN}+${git_staged}${RST}"
  [ "${git_modified:-0}" -gt 0 ] && line1="${line1} ${YELLOW}~${git_modified}${RST}"
  line1="${line1})"
fi

if [ -n "$github_url" ]; then
  line1="${line1} ${LINK_OPEN}${github_url}${LINK_CLOSE}${CYAN_UL}GitHub>${RST}${LINK_OPEN}${LINK_CLOSE}"
fi

if [ -n "$plan_name" ]; then
  line1="${line1} | ${GREEN}plan:${plan_name}${RST}"
fi

# --- Line 2: Bar, usage, cost, duration, diff ---
used_pct=$(awk 'BEGIN { printf "%d", int('"$used_pct"') }')
current_tokens=$((current_input_tokens + cache_create_tokens + cache_read_tokens))
if [ "$current_tokens" -gt 0 ] 2>/dev/null; then
  used_tokens=$current_tokens
else
  used_tokens=$((used_pct * window_size / 100))
fi

bar_w=20
filled=$((used_pct * bar_w / 100))
empty=$((bar_w - filled))

if [ "$used_pct" -lt 70 ]; then bar_color="$GREEN"
elif [ "$used_pct" -lt 90 ];  then bar_color="$YELLOW"
else                                bar_color="$RED"
fi

bar_filled=$(printf "%${filled}s" '' | sed 's/ /█/g')
bar_empty=$(printf "%${empty}s"   '' | sed 's/ /░/g')
bar="${bar_color}${bar_filled}${DIM}${bar_empty}${RST}"

# Cost (color-coded)
cost_cmp=$(awk 'BEGIN { print ('"$cost"' > 5) ? "red" : ('"$cost"' >= 1) ? "yellow" : "green" }')
cost_val=$(printf "%.2f" "$cost")
case "$cost_cmp" in
  red)    cost_fmt="${RED}\$${cost_val}${RST}" ;;
  yellow) cost_fmt="${YELLOW}\$${cost_val}${RST}" ;;
  *)      cost_fmt="${GREEN}\$${cost_val}${RST}" ;;
esac

# Duration
total_s=$((duration_ms / 1000))
hrs=$((total_s / 3600))
mins=$(( (total_s % 3600) / 60 ))
secs=$((total_s % 60))
[ "$hrs" -gt 0 ] && duration="${hrs}h${mins}m" || duration="${mins}m${secs}s"

# Lines changed
diff_stat="${GREEN}+${lines_added}${RST}/${RED}-${lines_removed}${RST}"

# Tip
tip=""
if   [ "$used_pct" -gt 90 ]; then tip=" | ${RED}!! /compact or /clear${RST}"
elif [ "$used_pct" -gt 75 ]; then tip=" | ${YELLOW}! Consider /compact${RST}"
elif [ "$used_pct" -gt 50 ]; then tip=" | ${DIM}Summarize if stuck${RST}"
fi

effort_seg=$(render_effort "$effort_level")
line2="[${bar}] ${used_pct}% $(fmt_k "$used_tokens")/$(fmt_k "$window_size") | ${cost_fmt} ${duration} ${diff_stat}${effort_seg}${subscription_seg}${tip}"

printf '%s\n%s\n' "$line1" "$line2"

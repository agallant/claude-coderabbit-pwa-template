#!/usr/bin/env bash
# Shows where this repo stands with CodeRabbit's review allowance (about one review an hour per
# repo, shared by every session working here), so sessions can take turns instead of colliding.
#
#   .github/scripts/coderabbit-queue.sh [owner/repo]
#
# Prints when CodeRabbit last reviewed, when the next review is available, and which open PRs
# are waiting for a review of their latest commit, in turn order. Read-only; needs `gh`.
set -euo pipefail

repo="${1:-}"
if [ -z "$repo" ]; then
  url="$(git remote get-url origin)"
  repo="$(printf '%s' "$url" | sed -E 's#\.git$##; s#^.*[:/]([^/]+/[^/]+)$#\1#')"
fi
bot='coderabbitai[bot]'
window=3600

last=""
last_pr=""
waiting=()
# Recently updated PRs cover every review from the last hour.
while read -r number state draft author sha; do
  reviews="$(gh api "repos/$repo/pulls/$number/reviews?per_page=100" \
    --jq ".[] | select(.user.login==\"$bot\") | \"\(.submitted_at) \(.commit_id)\"")"
  newest="$(printf '%s\n' "$reviews" | sort | tail -n 1 | cut -d' ' -f1)"
  if [ -n "$newest" ] && [[ "$newest" > "$last" ]]; then
    last="$newest"
    last_pr="$number"
  fi
  # Waiting: open, ready, a person's PR, and CodeRabbit hasn't reviewed its head commit.
  if [ "$state" = open ] && [ "$draft" = false ] && [ "$author" != 'dependabot[bot]' ] &&
    ! printf '%s\n' "$reviews" | grep -q " $sha\$"; then
    waiting+=("$number")
  fi
done < <(gh api "repos/$repo/pulls?state=all&sort=updated&direction=desc&per_page=30" \
  --jq '.[] | "\(.number) \(.state) \(.draft) \(.user.login) \(.head.sha)"')

now="$(date -u +%s)"
if [ -z "$last" ]; then
  echo "Last CodeRabbit review: none found. A review is available now."
else
  next=$(($(date -u -d "$last" +%s) + window))
  if [ "$next" -le "$now" ]; then
    echo "Last CodeRabbit review: $last (#$last_pr). A review is available now."
  else
    echo "Last CodeRabbit review: $last (#$last_pr). Next review available at" \
      "$(date -u -d "@$next" +%H:%M) UTC, in $(((next - now + 59) / 60)) min."
  fi
fi

if [ "${#waiting[@]}" -eq 0 ]; then
  echo "No open PR is waiting for a review."
else
  sorted="$(printf '%s\n' "${waiting[@]}" | sort -n | sed 's/^/#/' | paste -sd' ' -)"
  echo "Waiting for a review, in turn order: $sorted"
fi

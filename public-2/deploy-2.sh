#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBLIC_REPO="/tmp/obsidian-public"

cd "$SCRIPT_DIR"

# 빌드
rm -rf public .quartz-cache
npx quartz build -d .

# 배포
if [ ! -d "$PUBLIC_REPO/.git" ]; then
  rm -rf "$PUBLIC_REPO"
  git clone git@github.com:qodot/obsidian-public.git "$PUBLIC_REPO"
fi

cd "$PUBLIC_REPO"
git pull --ff-only origin main 2>/dev/null || true
rm -rf *
cp -r "$SCRIPT_DIR/public/"* .
git add -A

if git diff --cached --quiet; then
  echo "변경사항 없음"
else
  git commit -m "Deploy $(date '+%Y-%m-%d %H:%M')"
  git push
  echo "배포 완료"
fi

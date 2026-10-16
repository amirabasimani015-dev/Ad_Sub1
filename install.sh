#!/usr/bin/env bash
# ADRENALIN subscription page installer for PasarGuard
#   نصب:        sudo bash -c "$(curl -sL https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main/install.sh)"
#   حذف/برگشت:  sudo bash -c "$(curl -sL https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main/install.sh)" @ uninstall
# این اسکریپت کوچک است و فایل صفحه (index.html) را از همان ریپو دانلود می‌کند.
# متغیرهای اختیاری:
#   PG_DIR=/opt/pasarguard  PG_DATA=/var/lib/pasarguard
#   ADR_BASE_URL=https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main
#   ADR_HTML=/مسیر/محلی/index.html   (اگر فایل را خودت روی سرور گذاشته‌ای)
set -euo pipefail

BASE_URL="${ADR_BASE_URL:-https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main}"
PG_DIR="${PG_DIR:-/opt/pasarguard}"
PG_DATA="${PG_DATA:-/var/lib/pasarguard}"
ENVF="$PG_DIR/.env"
TPL_DIR="$PG_DATA/templates"
TPL_FILE="$TPL_DIR/subscription/index.html"
ORIG="$TPL_FILE.orig-adrenalin"
ENV_BAK="$PG_DIR/.env.adrenalin.bak"
# فایل‌های پینگ نسخه‌های قبلی (فقط برای پاک‌سازی)
PING_JSON="$TPL_DIR/subscription/adr-ping.json"
PING_BIN="${PING_BIN:-/usr/local/bin/adrenalin-ping}"
PING_CONF="${PING_CONF:-/etc/adrenalin-ping.conf}"
SD_DIR="${SD_DIR:-/etc/systemd/system}"
CRON_FILE="${CRON_FILE:-/etc/cron.d/adrenalin-ping}"

say(){ printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn(){ printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }
[ "$(id -u)" = 0 ] || die "با root اجرا کن:  sudo bash install.sh"
[ -f "$ENVF" ]     || die "فایل $ENVF پیدا نشد. مسیر پنل را با PG_DIR بده."

setenv(){ # همه خطوط قبلی (فعال/کامنت) پاک می‌شوند و یک خط تمیز اضافه می‌شود
  sed -i -E "/^[#[:space:]]*$1[[:space:]]*=/d" "$ENVF"
  printf '%s="%s"\n' "$1" "$2" >> "$ENVF"
}
restart_panel(){
  if command -v pasarguard >/dev/null 2>&1; then pasarguard restart -n || pasarguard restart
  elif [ -f "$PG_DIR/docker-compose.yml" ]; then (cd "$PG_DIR" && docker compose up -d --force-recreate)
  else say "پنل را دستی ریستارت کن: pasarguard restart"; fi
}
has_systemd(){ command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; }
clean_old_ping(){
  if has_systemd; then systemctl disable --now adrenalin-ping.timer >/dev/null 2>&1 || true; fi
  rm -f "$SD_DIR/adrenalin-ping.service" "$SD_DIR/adrenalin-ping.timer" "$CRON_FILE" "$PING_BIN" "$PING_JSON" "$PING_CONF"
  if has_systemd; then systemctl daemon-reload >/dev/null 2>&1 || true; fi
}

if [ "${1:-}" = "uninstall" ]; then
  [ -f "$ENV_BAK" ] && cp -f "$ENV_BAK" "$ENVF" && say ".env از بکاپ برگشت"
  if [ -f "$ORIG" ]; then mv -f "$ORIG" "$TPL_FILE"; say "قالب قبلی برگشت"; else rm -f "$TPL_FILE"; fi
  clean_old_ping
  restart_panel; say "حذف شد"; exit 0
fi

[ -d "$PG_DATA" ] || die "پوشه $PG_DATA پیدا نشد. مسیر دیتا را با PG_DATA بده."

# ---------- ۱) گرفتن فایل صفحه و بررسی سالم بودنش (قبل از دست زدن به پنل) ----------
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
if [ -n "${ADR_HTML:-}" ]; then
  [ -f "$ADR_HTML" ] || die "فایل $ADR_HTML پیدا نشد."
  cp "$ADR_HTML" "$TMP"
elif [ -f "$0" ] && [ -f "$(dirname "$0")/index.html" ]; then
  cp "$(dirname "$0")/index.html" "$TMP"
else
  command -v curl >/dev/null 2>&1 || die "curl نصب نیست:  apt install -y curl"
  say "دانلود صفحه از: $BASE_URL/index.html"
  curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 "$BASE_URL/index.html" -o "$TMP" \
    || die "دانلود index.html ناموفق بود. ریپو باید Public باشد و فایل index.html در ریشه‌ی آن قرار داشته باشد."
fi
SIZE="$(wc -c < "$TMP" | tr -d ' ')"
{ [ "$SIZE" -gt 20000 ] && grep -q 'id="pg-links"' "$TMP" && grep -q '{{ links' "$TMP" && grep -q '</html>' "$TMP"; } \
  || die "فایل index.html ناقص یا خراب است (حجم: $SIZE بایت). آن را دوباره در گیت‌هاب آپلود کن؛ چیزی روی پنل تغییر نکرد."
say "فایل صفحه سالم است ($SIZE بایت)"

# ---------- ۲) نصب ----------
mkdir -p "$TPL_DIR/subscription"
[ -f "$ENV_BAK" ] || cp "$ENVF" "$ENV_BAK"
# قالب قبلی را فقط اگر قالب خودِ ما نباشد نگه می‌داریم
if [ -f "$TPL_FILE" ] && [ ! -f "$ORIG" ] && ! grep -q 'id="pg-links"' "$TPL_FILE"; then cp "$TPL_FILE" "$ORIG"; fi
install -m 644 "$TMP" "$TPL_FILE"
[ -s "$TPL_FILE" ] || die "نوشتن قالب ناموفق بود"
say "قالب نوشته شد: $TPL_FILE"

setenv CUSTOM_TEMPLATES_DIRECTORY "$TPL_DIR/"
setenv SUBSCRIPTION_PAGE_TEMPLATE "subscription/index.html"
say ".env تنظیم شد"

# پینگ حذف شده است؛ اگر نسخه‌های قبلی تایمر/اسکریپت پینگ نصب کرده بودند پاک می‌شود
clean_old_ping

restart_panel
say "تمام. لینک ساب یک کاربر را در مرورگر باز کن (Ctrl+F5)."

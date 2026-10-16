<div dir="rtl">

# صفحه اشتراک ADRENALIN برای پنل پاسارگاد (PasarGuard)

یک صفحه‌ی اشتراک (ساب) زیبا و سریع برای [پاسارگاد](https://github.com/PasarGuard/panel) که وقتی کاربر لینک ساب را در مرورگر باز می‌کند نمایش داده می‌شود. اپ‌های کلاینت (v2rayNG، Hiddify و…) مثل قبل کانفیگ می‌گیرند و اتصال کاربران تغییری نمی‌کند.

## امکانات

- نمایش زنده‌ی حجم کل، مصرف‌شده، باقی‌مانده، تاریخ انقضا و شمارش معکوس
- **کانفیگ وایرگارد (WireGuard):** دانلود فایل `.conf`، کپی متن کانفیگ و QR کد
- دکمه‌ی «دانلود همه (ZIP)» برای فایل‌های وایرگارد، مستقیم از خود پنل
- کپی و QR کد برای همه‌ی کانفیگ‌ها و لینک اشتراک
- افزودن سریع به اپ‌ها (اندروید، iOS، ویندوز، لینوکس)
- چهار زبان (فارسی، انگلیسی، چینی، عربی)، تم تیره و روشن، انتخاب رنگ
- بدون وابستگی به سایت بیرونی (QR و فونت داخل خود فایل هستند)؛ در ایران هم بدون مشکل لود می‌شود

## پیش‌نیاز

- پنل پاسارگاد نصب‌شده (مسیر پیش‌فرض: فایل `.env` در `/opt/pasarguard` و دیتا در `/var/lib/pasarguard`)
- دسترسی root روی سرور

## نصب (یک دستور)

روی سرور پنل، با کاربر root اجرا کن:

```bash
sudo bash -c "$(curl -sL https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main/install.sh)"
```

اسکریپت به‌ترتیب:

1. از `.env` پنل بکاپ می‌گیرد
2. فایل `index.html` را از همین ریپو دانلود و سالم بودنش را بررسی می‌کند، سپس قالب را در `/var/lib/pasarguard/templates/subscription/index.html` می‌نویسد
3. دو خط تنظیمات قالب را در `.env` اضافه می‌کند
4. پنل را ریستارت می‌کند

بعد از نصب، لینک ساب یک کاربر را در مرورگر باز کن و `Ctrl+F5` بزن.

اگر مسیر پنل شما فرق دارد:

```bash
sudo PG_DIR=/مسیر/پنل PG_DATA=/مسیر/دیتا bash -c "$(curl -sL https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main/install.sh)"
```

## آپدیت

همان دستور نصب را دوباره اجرا کن. نسخه‌ی جدید جایگزین قبلی می‌شود.

## حذف و برگشت به حالت قبل

```bash
sudo bash -c "$(curl -sL https://github.com/amirabasimani015-dev/Ad_Sub1/raw/main/install.sh)" @ uninstall
```

این دستور `.env` را از بکاپ برمی‌گرداند، قالب قبلی را (اگر بود) سر جایش می‌گذارد و پنل را ریستارت می‌کند.

## تنظیمات پنل که باید درست باشد

- در تنظیمات اشتراک پنل، گزینه‌ی **allow_browser_config** باید روشن باشد، وگرنه کانفیگ‌ها در صفحه نمی‌آیند.
- گزینه‌ی **disable_sub_template** باید خاموش باشد.
- اگر برای یک ادمین قالب اختصاصی (`sub_template`) گذاشته‌ای، آن قالب اولویت دارد. نام آن را `subscription/index.html` بگذار یا خالی بگذار.
- اگر HWID اجباری برای دریافت دستی روشن باشد، پنل کانفیگ را برای مرورگر نمی‌دهد.

## عیب‌یابی

| مشکل | راه‌حل |
|---|---|
| خروجی `404` یا اسکریپت اجرا نشد | ریپو باید Public باشد و فایل `install.sh` در ریشه‌ی ریپو باشد |
| پیام «فایل index.html ناقص یا خراب است» | فایل `index.html` در گیت‌هاب کامل آپلود نشده؛ دوباره آپلودش کن (چیزی روی پنل تغییر نکرده است) |
| سرور به گیت‌هاب نمی‌رسد | `install.sh` را با `scp` به سرور بفرست و با `sudo bash install.sh` اجرا کن |
| صفحه‌ی ۵۰۰ می‌دهد | `pasarguard logs \| tail -n 50` و `grep -n TEMPLATE /opt/pasarguard/.env` را بزن |
| تغییر دیده نمی‌شود | `Ctrl+F5` بزن؛ کش مرورگر یا Cloudflare را پاک کن؛ `pasarguard restart` را بزن |
| کانفیگ‌ها خالی است | تنظیمات بالا (allow_browser_config و HWID) را چک کن |
| دکمه‌ی وایرگارد نمی‌آید | کاربر باید کانفیگ وایرگارد داشته باشد. تست: `curl -s -H "Accept: application/json" https://دامنه:پورت/sub/توکن/info` |

نکته: داخل مرورگر تلگرام و اینستاگرام دانلود فایل معمولاً بلاک است. در آن‌جا صفحه به‌جای دانلود، پنجره‌ای با کپی متن و لینک ZIP نشان می‌دهد؛ یا لینک را در Chrome/Safari باز کن.

## فایل‌های این ریپو

| فایل | توضیح |
|---|---|
| `install.sh` | اسکریپت نصب (کوچک است؛ فایل `index.html` را از همین ریپو دانلود و بررسی می‌کند) |
| `index.html` | خود صفحه، برای ویرایش یا نصب دستی |
| `RAHNAMA.txt` | راهنمای کامل فارسی |

## نصب دستی (بدون اسکریپت)

```bash
mkdir -p /var/lib/pasarguard/templates/subscription
cp /opt/pasarguard/.env /opt/pasarguard/.env.bak
# فایل index.html را اینجا بگذار:
#   /var/lib/pasarguard/templates/subscription/index.html
nano /opt/pasarguard/.env
```

این دو خط را در `.env` اضافه کن (اگر هست، عوضشان کن و `#` اولشان نباشد):

```
CUSTOM_TEMPLATES_DIRECTORY="/var/lib/pasarguard/templates/"
SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"
```

سپس `pasarguard restart` را بزن. اول مطمئن شو فایل `index.html` سر جایش هست و بعد `.env` را عوض کن.

## تغییر لینک‌های تلگرام

لینک کانال، پشتیبانی و ربات در انتهای `index.html` هستند. فایل را باز کن و دنبال `t.me` بگرد.

## مجوز

کتابخانه‌ی QR داخل صفحه [qrcode-generator](https://github.com/kazuhikoarase/qrcode-generator) است (مجوز MIT، © Kazuhiko Arase).

</div>

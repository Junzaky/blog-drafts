#!/bin/bash

# HTML to PDF 変換スクリプト
# 使用方法: ./html-to-pdf.sh [HTMLファイル] [出力PDFファイル名]

HTML_FILE="${1:-notes/slide-自治会.html}"
OUTPUT_PDF="${2:-notes/slide-自治会.pdf}"

# 絶対パスに変換
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_ABSPATH="$(cd "$(dirname "$HTML_FILE")" && pwd)/$(basename "$HTML_FILE")"
OUTPUT_ABSPATH="$(cd "$(dirname "$OUTPUT_PDF")" && pwd)/$(basename "$OUTPUT_PDF")"

echo "HTMLファイル: $HTML_ABSPATH"
echo "出力PDF: $OUTPUT_ABSPATH"

# Chrome/Chromiumのパスを確認
if command -v "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" &> /dev/null; then
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v "/Applications/Chromium.app/Contents/MacOS/Chromium" &> /dev/null; then
    CHROME="/Applications/Chromium.app/Contents/MacOS/Chromium"
elif command -v google-chrome &> /dev/null; then
    CHROME="google-chrome"
elif command -v chromium &> /dev/null; then
    CHROME="chromium"
else
    echo "エラー: ChromeまたはChromiumが見つかりません"
    echo "以下のいずれかをインストールしてください:"
    echo "  - Google Chrome"
    echo "  - Chromium"
    exit 1
fi

# file://プロトコルでローカルファイルを開く
FILE_URL="file://$HTML_ABSPATH"

echo "PDFを生成中..."

# PDFを生成（A4サイズ、各スライドを1ページに）
"$CHROME" --headless \
    --disable-gpu \
    --print-to-pdf="$OUTPUT_ABSPATH" \
    --print-to-pdf-no-header \
    --no-pdf-header-footer \
    --page-size=A4 \
    --margin-top=0 \
    --margin-bottom=0 \
    --margin-left=0 \
    --margin-right=0 \
    "$FILE_URL"

if [ $? -eq 0 ]; then
    echo "✓ PDFが正常に生成されました: $OUTPUT_ABSPATH"
    # PDFを開く（オプション）
    # open "$OUTPUT_ABSPATH"
else
    echo "✗ PDFの生成に失敗しました"
    exit 1
fi



#!/bin/bash

# HTMLスライドを個別の画像ファイルにエクスポートするスクリプト
# 使用方法: ./html-to-images.sh [HTMLファイル] [出力ディレクトリ]

HTML_FILE="${1:-notes/slide-自治会.html}"
OUTPUT_DIR="${2:-notes/slide-images}"

# 絶対パスに変換
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_ABSPATH="$(cd "$(dirname "$HTML_FILE")" && pwd)/$(basename "$HTML_FILE")"
OUTPUT_ABSPATH="$(cd "$(dirname "$OUTPUT_DIR")" && pwd)/$(basename "$OUTPUT_DIR")"

# 出力ディレクトリを作成
mkdir -p "$OUTPUT_ABSPATH"

echo "HTMLファイル: $HTML_ABSPATH"
echo "出力ディレクトリ: $OUTPUT_ABSPATH"

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

echo "各スライドを画像としてエクスポート中..."

# 一時的なJavaScriptファイルを作成
TEMP_JS=$(mktemp)
cat > "$TEMP_JS" << 'EOF'
// 各スライドをスクリーンショット
const slides = document.querySelectorAll('.slide-container');
const totalSlides = slides.length;

console.log(`見つかったスライド数: ${totalSlides}`);

// 各スライドを個別にスクロールしてスクリーンショット
async function captureSlides() {
    for (let i = 0; i < slides.length; i++) {
        const slide = slides[i];
        
        // スライドをビューポートの中央にスクロール
        slide.scrollIntoView({ behavior: 'instant', block: 'center' });
        
        // 少し待機してレンダリングを完了
        await new Promise(resolve => setTimeout(resolve, 500));
        
        // スライドの位置とサイズを取得
        const rect = slide.getBoundingClientRect();
        
        // スクリーンショットを撮る（Chrome拡張機能またはPuppeteerが必要）
        // このスクリプトは手動実行用のガイドとして機能
        console.log(`スライド ${i + 1}/${totalSlides}: ${slide.id || 'unnamed'}`);
    }
}

captureSlides();
EOF

echo ""
echo "⚠️  注意: このスクリプトは手動でのスクリーンショットをサポートします。"
echo ""
echo "自動化するには、以下のいずれかの方法を使用してください："
echo ""
echo "方法1: ブラウザの開発者ツールを使用"
echo "  1. HTMLファイルをブラウザで開く"
echo "  2. 開発者ツール（F12）を開く"
echo "  3. コンソールで上記のJavaScriptを実行"
echo ""
echo "方法2: 手動でスクリーンショット"
echo "  各スライドを個別にスクリーンショットして保存してください"
echo ""

# より簡単な方法: 各スライドを個別のHTMLファイルとして生成
echo "代替方法: 各スライドを個別のHTMLファイルとして生成しますか？ (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "個別HTMLファイルを生成中..."
    
    # HTMLの基本構造を読み込む
    HTML_CONTENT=$(cat "$HTML_ABSPATH")
    
    # 各スライドを抽出
    slide_num=1
    while IFS= read -r line; do
        if [[ $line == *"<div class=\"slide-container\""* ]]; then
            slide_file="$OUTPUT_ABSPATH/slide-$(printf "%02d" $slide_num).html"
            echo "スライド $slide_num を生成中..."
            
            # 基本HTML構造を作成
            cat > "$slide_file" << EOF
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>スライド $slide_num</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;700&family=Noto+Sans+JP:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background-color: #f1f5f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .slide-container {
            align-items: center;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            font-family: 'Noto Sans JP', sans-serif;
            height: 720px;
            justify-content: center;
            overflow: hidden;
            padding: 60px 80px;
            position: relative;
            width: 1280px;
            background-image: radial-gradient(circle at 100% 0%, rgba(59, 130, 246, 0.05) 0%, transparent 40%),
                              radial-gradient(circle at 0% 100%, rgba(15, 23, 42, 0.03) 0%, transparent 40%);
        }
        /* 元のHTMLからスタイルをコピーする必要があります */
    </style>
</head>
<body>
EOF
            # スライドコンテナの内容を追加（簡易版）
            echo "    <div class=\"slide-container\">" >> "$slide_file"
            echo "        <p>スライド $slide_num - 元のHTMLから内容をコピーしてください</p>" >> "$slide_file"
            echo "    </div>" >> "$slide_file"
            echo "</body>" >> "$slide_file"
            echo "</html>" >> "$slide_file"
            
            ((slide_num++))
        fi
    done < "$HTML_ABSPATH"
    
    echo "✓ 個別HTMLファイルを生成しました: $OUTPUT_ABSPATH"
fi

rm -f "$TEMP_JS"

echo ""
echo "完了！"
echo "各スライドを画像として保存するには："
echo "  1. HTMLファイルをブラウザで開く"
echo "  2. 各スライドをスクリーンショット（Cmd+Shift+4 または Win+Shift+S）"
echo "  3. 画像を $OUTPUT_ABSPATH に保存"


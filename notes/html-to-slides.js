// HTMLスライドを個別の画像ファイルにエクスポートするスクリプト
// 使用方法: node html-to-slides.js [HTMLファイル] [出力ディレクトリ]

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const HTML_FILE = process.argv[2] || path.join(__dirname, 'slide-自治会.html');
const OUTPUT_DIR = process.argv[3] || path.join(__dirname, 'slide-images');

// 出力ディレクトリを作成
if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

(async () => {
    console.log('ブラウザを起動中...');
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    
    // ビューポートサイズを設定（スライドサイズに合わせる）
    await page.setViewport({
        width: 1280,
        height: 800,
        deviceScaleFactor: 2 // 高解像度
    });
    
    const filePath = path.resolve(HTML_FILE);
    const fileUrl = `file://${filePath}`;
    
    console.log(`HTMLファイルを読み込み中: ${fileUrl}`);
    await page.goto(fileUrl, { waitUntil: 'networkidle0' });
    
    // スライド要素を取得
    const slides = await page.$$('.slide-container');
    console.log(`見つかったスライド数: ${slides.length}`);
    
    for (let i = 0; i < slides.length; i++) {
        console.log(`スライド ${i + 1}/${slides.length} を処理中...`);
        
        // スライドをビューポートの中央にスクロール
        await page.evaluate((index) => {
            const slides = document.querySelectorAll('.slide-container');
            if (slides[index]) {
                slides[index].scrollIntoView({ behavior: 'instant', block: 'center' });
            }
        }, i);
        
        // レンダリングを待機
        await page.waitForTimeout(500);
        
        // スライドの位置とサイズを取得
        const boundingBox = await slides[i].boundingBox();
        
        if (boundingBox) {
            // スライドをスクリーンショット
            const outputPath = path.join(OUTPUT_DIR, `slide-${String(i + 1).padStart(2, '0')}.png`);
            await slides[i].screenshot({
                path: outputPath,
                type: 'png',
                clip: {
                    x: boundingBox.x,
                    y: boundingBox.y,
                    width: boundingBox.width,
                    height: boundingBox.height
                }
            });
            
            console.log(`  ✓ 保存: ${outputPath}`);
        }
    }
    
    await browser.close();
    console.log(`\n完了！${slides.length}個のスライド画像を ${OUTPUT_DIR} に保存しました。`);
    console.log('\n次のステップ:');
    console.log('1. Googleスライドを開く');
    console.log('2. 各画像を「挿入」→「画像」→「アップロード」で追加');
    console.log('3. 各画像を1つのスライドとして配置');
})();


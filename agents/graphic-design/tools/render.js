// Render an SVG file to a PNG at a given pixel size using headless Chromium.
// Usage: node agents/graphic-design/tools/render.js <in.svg> <out.png> <size-px> [background]
// Example: node agents/graphic-design/tools/render.js icon.svg preview-60.png 60 "#FAF7F2"
// Runs offline. No network calls.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  const [inFile, outFile, sizeArg, bg] = process.argv.slice(2);
  if (!inFile || !outFile || !sizeArg) {
    console.error('Usage: node render.js <in.svg> <out.png> <size-px> [background]');
    process.exit(1);
  }
  const size = parseInt(sizeArg, 10);
  const svg = fs.readFileSync(path.resolve(inFile), 'utf8');
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: size, height: size },
    deviceScaleFactor: 1,
  });
  await page.setContent(
    `<html><body style="margin:0;background:${bg || 'transparent'}">
     <div id="w" style="width:${size}px;height:${size}px;display:flex;align-items:center;justify-content:center">${svg}</div>
     <style>#w svg{width:100%;height:100%}</style></body></html>`
  );
  await page.locator('#w').screenshot({ path: path.resolve(outFile), omitBackground: !bg });
  await browser.close();
  console.log(`Wrote ${outFile} at ${size}x${size}`);
})();

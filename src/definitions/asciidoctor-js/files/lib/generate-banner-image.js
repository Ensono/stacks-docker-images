function escapeXml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function createBannerSvg({ text, width, height, bgColor, fontColor, fontSize, fontWeight }) {
  return `
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-label="${escapeXml(text)}">
  <rect width="100%" height="100%" fill="${bgColor}"/>
  <text x="50%" y="50%" fill="${fontColor}" font-size="${fontSize}" font-family="Arial, sans-serif" font-weight="${fontWeight}" text-anchor="middle" dominant-baseline="middle">${escapeXml(text)}</text>
</svg>
  `.trim();
}

module.exports.register = function (registry) {
  registry.block(function () {
    this.named('banner_image');
    this.onContext(['paragraph']);
    this.process(function (parent, reader, attrs) {
      const text = (attrs.text || attrs.title || 'Banner Text').trim();
      const width = Number.parseInt(attrs.width || '300', 10) || 300;
      const height = Number.parseInt(attrs.height || '45', 10) || 45;
      const bgColor = attrs.bg_color || attrs.background_color || 'red';
      const fontColor = attrs.font_color || 'white';
      const fontSize = Number.parseInt(attrs.font_size || '20', 10) || 20;
      const fontWeight = Number.parseInt(attrs.font_weight || '100', 10) || 100;
      const svg = createBannerSvg({ text, width, height, bgColor, fontColor, fontSize, fontWeight });
      return this.createBlock(parent, 'pass', svg);
    });
  });
};

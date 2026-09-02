const qrcode = require('qrcode-generator');

function toPositiveInteger(value, fallback) {
  const parsedValue = Number.parseInt(value, 10);
  return Number.isFinite(parsedValue) && parsedValue > 0 ? parsedValue : fallback;
}

module.exports.register = function (registry) {
  registry.blockMacro(function () {
    this.named('qrcode');
    this.process(function (parent, target, attrs) {
      const moduleSize = toPositiveInteger(attrs.xdim || attrs.ydim, 2);
      const margin = toPositiveInteger(attrs.margin, 4);
      const qrCode = qrcode(0, attrs.level || 'M');

      qrCode.addData(target);
      qrCode.make();

      return this.createBlock(parent, 'pass', qrCode.createSvgTag(moduleSize, margin), attrs);
    });
  });
};
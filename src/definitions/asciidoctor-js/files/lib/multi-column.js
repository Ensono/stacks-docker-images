module.exports.register = function (registry) {
  registry.docinfoProcessor(function () {
    this.atLocation('header');
    this.process(function () {
      return `
<style>
  .two-column-layout,
  .sect1.headlines > .sectionbody {
    column-count: 2;
    column-gap: 2rem;
  }
</style>
      `.trim();
    });
  });

  registry.block(function () {
    this.named('headlines');
    this.onContext(['paragraph']);
    this.process(function (parent, reader, attrs) {
      const content = reader.getLines().join('\n');
      return this.createBlock(parent, 'open', content, {
        role: 'two-column-layout',
        ...attrs
      });
    });
  });
};

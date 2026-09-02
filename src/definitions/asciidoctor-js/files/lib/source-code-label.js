module.exports.register = function (registry) {
  registry.docinfoProcessor(function () {
    this.atLocation('header');
    this.process(function () {
      return `
<style>
  .listingblock[data-language] {
    position: relative;
    margin-top: 1rem;
  }
  .listingblock[data-language]::before {
    content: attr(data-language);
    position: absolute;
    top: 0.25rem;
    right: 0.75rem;
    font-size: 0.7rem;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #666;
    background: rgba(255, 255, 255, 0.8);
    padding: 0.1rem 0.45rem;
    border-radius: 0.2rem;
  }
</style>
      `.trim();
    });
  });

  registry.block(function () {
    this.named('listing');
    this.onContext('listing');
    this.process(function (parent, reader, attrs) {
      const content = reader.getLines().join('\n');
      const language = attrs.language || attrs.lang || '';
      const updatedAttrs = { ...attrs };

      if (language) {
        updatedAttrs['data-language'] = language;
      }

      return this.createBlock(parent, 'listing', content, updatedAttrs);
    });
  });
};

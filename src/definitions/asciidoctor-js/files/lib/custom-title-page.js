function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function parseBackgroundImage(value) {
  const match = String(value || '').match(/^image:(.*?)(?:\[(.*?)\])?$/);
  if (!match) {
    return null;
  }

  const position = (match[2] || '').match(/(?:^|,)\s*position=([^,\s]+)/);
  const url = match[1].trim().replace(/['"\\]/g, '\\$&');

  return {
    url,
    position: position ? position[1] : 'center'
  };
}

module.exports.register = function (registry) {
  registry.docinfoProcessor(function () {
    this.atLocation('header');
    this.process(function (doc) {
      const title = escapeHtml(doc.getDocumentTitle() || doc.getTitle() || '');
      const subtitle = escapeHtml(doc.getAttribute('subtitle') || '');
      const backgroundImage = parseBackgroundImage(doc.getAttribute('title-page-background-image'));
      const backgroundStyle = backgroundImage
        ? ` style="background-image: url('${backgroundImage.url}'); background-position: ${escapeHtml(backgroundImage.position)};"`
        : '';

      return `
<style>
  .custom-title-page {
    text-align: center;
    margin: 3rem 0 4rem 0;
    page-break-after: always;
    background-repeat: no-repeat;
    background-size: cover;
    min-height: 100vh;
  }
  .custom-title-page h1 {
    font-size: 2.5rem;
    line-height: 1.2;
    margin: 0;
  }
  .custom-title-page h2 {
    font-size: 1.25rem;
    margin: 0.5rem 0 0;
    font-weight: 400;
  }
</style>
<div class="custom-title-page"${backgroundStyle}>
  <h1>${title}</h1>
  ${subtitle ? `<h2>${subtitle}</h2>` : ''}
</div>
      `.trim();
    });
  });
};

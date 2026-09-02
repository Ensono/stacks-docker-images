const fs = require('node:fs');
const path = require('node:path');

function register(registry) {
  registry.includeProcessor(function () {
    this.handles(function (target) {
      return target.includes('*');
    });

    this.process(function (document, reader, targetGlob, attributes) {
      const sourceDirectory = reader._dir;
      const targets = fs.globSync(targetGlob, {
        cwd: sourceDirectory,
      })
        .map((target) => path.resolve(sourceDirectory, target))
        .filter((target) => fs.statSync(target).isFile())
        .sort();

      for (let index = targets.length - 1; index >= 0; index -= 1) {
        const target = targets[index];
        const content = fs.readFileSync(target, 'utf8').split(/\r?\n/);

        if (!Object.hasOwn(attributes, 'adjoin-option')) content.unshift('');

        reader.pushInclude(content, target, target, 1, attributes);
      }
    });
  });
}

module.exports = register;
module.exports.register = register;
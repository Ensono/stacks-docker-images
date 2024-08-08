# Library declaration that allows files to be included in a document using a wildcard, rather
# than having to include the files individually

RUBY_ENGINE == 'opal' ? (require 'glob-include-processor/extension') : (require_relative 'glob-include-processor/extension')

Asciidoctor::Extensions.register do
  include_processor GlobIncludeProcessor
end

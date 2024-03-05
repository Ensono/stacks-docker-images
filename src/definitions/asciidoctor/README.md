# EIR Asciidoctor

A number of repositories that we have for Stacks have documentation in the Asciidoc format. This image contains all of the components required to run `asciidoctor` and turn the documentation into different formats.

The CLI can be added to, for example the `databricks` extension.

The image is built from the Ensono Java image, as there are components that are rely on Java to operate.

## Specs

**Platforms**: `linux/amd64`, `linux/arm64`

**Base Image**: ensno/eir-java

### Software

| Type | Name | Version | URL |
|---|---|---|---|
| Binary | Pandoc | 3.1.12.2 | https://github.com/jgm/pandoc/releases/download/3.1.12.2/pandoc-3.1.12.2-linux-amd64.tar.gz |
| Binary | Hugo | 0.123.7 | https://github.com/gohugoio/hugo/releases/download/v0.123.7/hugo_extended_0.123.7_linux-amd64.tar.gz |
| Gem | asciidoctor | 2.0.21 | https://rubygems.org/gems/asciidoctor |
| Gem | asciidoctor-pdf | 2.3.13 | https://rubygems.org/gems/asciidoctor-pdf |
| Gem | asciidoctor-confluence | 0.0.2 | https://rubygems.org/gems/asciidoctor-confluence |
| Gem | asciidoctor-diagram | 2.3.0 | https://rubygems.org/gems/asciidoctor-diagram |
| Gem | asciidoctor-epub3 | 2.1.0 | https://rubygems.org/gems/asciidoctor-epub3 |
| Gem | asciidoctor-fb2 | 0.7.0 | https://rubygems.org/gems/asciidoctor-fb2 |
| Gem | asciidoctor-mathematical | 0.3.5 | https://rubygems.org/gems/asciidoctor-mathematical |
| Gem | asciidoctor-revealjs | 5.1.0 | https://rubygems.org/gems/asciidoctor-revealjs | 
| Gem | asciidoctor-bibtex | 0.9.0 | https://rubygems.org/gems/asciidoctor-bibtex |
| Gem | asciidoctor-kroki | 0.9.1 | https://rubygems.org/gems/asciidoctor-kroki |
| Gem | asciidoctor-reducer | 1.0.6 | https://rubygems.org/gems/asciidoctor-reducer |
| Gem | kramdown_asciidoc | 2.1.0 | https://rubygems.org/gems/kramdown-asciidoc | 

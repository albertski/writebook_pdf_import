require_relative "lib/writebook_pdf_import/version"

Gem::Specification.new do |spec|
  spec.name        = "writebook_pdf_import"
  spec.version     = WritebookPdfImport::VERSION
  spec.authors     = [ "albertski" ]
  spec.summary     = "PDF import support for Writebook"
  spec.description = "A Rails engine that adds the ability to import PDF files into a Writebook book, creating pages and pictures from the PDF content."
  spec.license     = "MIT"

  spec.files = Dir[
    "app/**/*",
    "config/**/*",
    "lib/**/*",
    "MIT-LICENSE",
    "README.md"
  ]

  spec.add_dependency "rails"
  spec.add_dependency "pdf-reader", "~> 2.12"
  spec.add_dependency "mini_magick"
end

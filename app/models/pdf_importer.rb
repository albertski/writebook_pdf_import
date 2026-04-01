class PdfImporter
  class InvalidPdfError < StandardError; end

  def initialize(book, pdf_io)
    raise InvalidPdfError, "No PDF file provided" if pdf_io.blank?
    @book = book
    @reader = PDF::Reader.new(pdf_io)
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    raise InvalidPdfError, e.message
  end

  def import
    total = @reader.page_count
    ActiveRecord::Base.transaction do
      @reader.pages.each_with_index.flat_map do |raw_page, index|
        parsed = PdfPage.new(raw_page, index + 1)
        leaves = parsed.blank? ? [] : leaves_for(parsed)
        yield index + 1, total if block_given?
        leaves
      end
    end
  end

  private

    def leaves_for(pdf_page)
      leaves = []
      leaves << @book.press(Page.new(body: pdf_page.body), title: pdf_page.title) if pdf_page.body.present?
      pdf_page.pictures.each do |attachment|
        picture = Picture.new
        picture.image.attach(attachment)
        leaves << @book.press(picture, title: pdf_page.title)
      end
      leaves
    end
end

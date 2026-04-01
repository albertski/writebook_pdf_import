class PdfImportJob < ApplicationJob
  include ActionView::RecordIdentifier

  queue_as :default

  def perform(book, blob)
    blob.open do |file|
      PdfImporter.new(book, file).import do |current, total|
        percent = (current.to_f / total * 100).floor
        broadcast_progress(book, percent)
      end
    end
  rescue PdfImporter::InvalidPdfError, ArgumentError => e
    Rails.logger.error("PdfImportJob failed for book #{book.id}: #{e.class}: #{e.message}")
  ensure
    blob.purge
    Turbo::StreamsChannel.broadcast_refresh_to(book, "pdf_import")
  end

  private

    def broadcast_progress(book, percent)
      Turbo::StreamsChannel.broadcast_update_to(
        book, "pdf_import",
        target: dom_id(book, :pdf_import_body),
        partial: "books/imports/progress",
        locals: { percent: percent }
      )
    end
end

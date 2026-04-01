class Books::ImportsController < ApplicationController
  include BookScoped

  before_action :ensure_editable

  MAX_FILE_SIZE = 50.megabytes

  def create
    return unless valid_pdf?(params[:pdf])

    PdfImportJob.perform_later(@book, upload_pdf(params[:pdf]))

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          helpers.dom_id(@book, :pdf_import_body),
          partial: "books/imports/progress",
          locals: { percent: 0 }
        )
      end
      format.html { redirect_to book_slug_url(@book), notice: "PDF import started. Pages will appear shortly." }
    end
  rescue => e
    Rails.logger.error("PDF import enqueue failed: #{e.class}: #{e.message}")
    redirect_to book_slug_url(@book), alert: "Could not import PDF."
  end

  private

  def valid_pdf?(file)
    if file.blank? || file.content_type != "application/pdf"
      redirect_to book_slug_url(@book), alert: "Could not import PDF." and return false
    end

    if file.size > MAX_FILE_SIZE
      redirect_to book_slug_url(@book), alert: "PDF exceeds the #{MAX_FILE_SIZE / 1.megabyte}MB size limit." and return false
    end

    true
  end

  def upload_pdf(file)
    ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: "application/pdf"
    )
  end
end

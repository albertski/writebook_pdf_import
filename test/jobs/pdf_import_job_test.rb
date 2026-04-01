require "test_helper"

class PdfImportJobTest < ActiveJob::TestCase
  setup do
    @book = books(:handbook)
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: file_fixture("sample.pdf").open,
      filename: "sample.pdf",
      content_type: "application/pdf"
    )
  end

  test "imports leaves from the blob" do
    assert_difference -> { @book.leaves.active.count }, +2 do
      PdfImportJob.perform_now(@book, @blob)
    end
  end

  test "purges the blob after import" do
    PdfImportJob.perform_now(@book, @blob)
    assert_not ActiveStorage::Blob.exists?(@blob.id)
  end

  test "logs error and purges blob when PDF is invalid" do
    bad_blob = ActiveStorage::Blob.create_and_upload!(
      io: file_fixture("reading.webp").open,
      filename: "bad.pdf",
      content_type: "application/pdf"
    )

    log_output = StringIO.new
    previous_logger = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(log_output)

    assert_no_difference -> { Leaf.count } do
      PdfImportJob.perform_now(@book, bad_blob)
    end

    assert_match "PdfImportJob failed", log_output.string
    assert_not ActiveStorage::Blob.exists?(bad_blob.id)
  ensure
    Rails.logger = previous_logger
  end
end

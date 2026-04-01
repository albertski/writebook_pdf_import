require "test_helper"

class Books::ImportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "create enqueues a PDF import job for a valid PDF" do
    assert_enqueued_with(job: PdfImportJob) do
      post book_import_path(books(:handbook)), params: {
        pdf: fixture_file_upload("sample.pdf", "application/pdf")
      }
    end

    assert_redirected_to book_slug_url(books(:handbook))
    assert_equal "PDF import started. Pages will appear shortly.", flash[:notice]
  end

  test "create renders turbo stream with progress bar for turbo requests" do
    assert_enqueued_with(job: PdfImportJob) do
      post book_import_path(books(:handbook)),
        params: { pdf: fixture_file_upload("sample.pdf", "application/pdf") },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_match "pdf_import_body", response.body
  end

  test "create with no file redirects with alert" do
    assert_no_enqueued_jobs do
      post book_import_path(books(:handbook))
    end

    assert_redirected_to book_slug_url(books(:handbook))
    assert_equal "Could not import PDF.", flash[:alert]
  end

  test "create with a non-PDF file redirects with alert" do
    assert_no_enqueued_jobs do
      post book_import_path(books(:handbook)), params: {
        pdf: fixture_file_upload("reading.webp", "image/webp")
      }
    end

    assert_redirected_to book_slug_url(books(:handbook))
    assert_equal "Could not import PDF.", flash[:alert]
  end
end

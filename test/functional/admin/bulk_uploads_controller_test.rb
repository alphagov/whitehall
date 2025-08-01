require "test_helper"

class Admin::BulkUploadsControllerTest < ActionController::TestCase
  setup do
    @edition = create(:news_article)
    login_as :gds_editor
    @titles = []
  end

  def params_for_attachment(attachment, index)
    file_cache = attachment.attachment_data.file_cache
    @titles << "Title #{index}"
    {
      title: @titles.last,
      attachment_data_attributes: { file_cache: },
    }
  end

  def valid_create_params
    files = %w[simple.pdf whitepaper.pdf].map { |f| upload_fixture(f) }
    bulk_upload = BulkUpload.new(@edition)
    bulk_upload.build_attachments_from_files(files)
    params = { attachments: {} }
    bulk_upload.attachments.each_with_index do |attachment, i|
      params[:attachments][i.to_s] = params_for_attachment(attachment, i + 1)
    end

    params
  end

  def invalid_create_params
    valid_create_params.tap do |params|
      params[:attachments]["0"][:title] = ""
    end
  end

  def post_to_upload_files(*files)
    params = {}

    params[:bulk_upload] = {
      files: files && files.map { |f| f && upload_fixture(f) },
    }

    post :upload_files, params: { edition_id: @edition }.merge(params)
  end

  test "Actions are unavailable on unmodifiable editions" do
    edition = create(:published_news_article)
    get :new, params: { edition_id: edition }
    assert_response :redirect
  end

  view_test "GET :new displays a bulk upload form" do
    get :new, params: { edition_id: @edition }

    assert_response :success
    assert_select "input[type=file]"
  end

  test "bulk upload access is forbidden for users without access to the edition" do
    login_as :world_editor
    get :new, params: { edition_id: @edition }
    assert_response :forbidden
  end

  view_test "POST :upload_files with no files requests that files be specified" do
    post_to_upload_files(nil)
    assert_select ".gem-c-error-summary__list-item", /Files not selected for upload/
  end

  view_test "POST :upload_files prompts for metadata for each file" do
    post_to_upload_files("two-pages.pdf", "greenpaper.pdf")
    assert_response :success
    assert_select "input[name='bulk_upload[attachments][0][title]']"
    assert_select "input[name='bulk_upload[attachments][1][title]']"
    assert_select ".govuk-fieldset__heading", /File: two-pages.pdf/
    assert_select ".govuk-fieldset__heading", /File: greenpaper.pdf/
  end

  view_test "POST :upload_files when replacing an attachment sets to_replace_id" do
    existing_file = File.open(Rails.root.join("test/fixtures/greenpaper.pdf"))
    @edition.attachments << existing = build(:file_attachment, file: existing_file)
    post_to_upload_files("two-pages.pdf", "greenpaper.pdf")
    assert_response :success
    assert_select "input[name*='to_replace_id'][value='#{existing.attachment_data.id}']"
  end

  view_test "POST :upload_files with illegal file" do
    post_to_upload_files("two-pages.pdf", "greenpaper.pdf", "pdfinfo_dummy.sh")
    assert_response :success
    assert_select ".gem-c-error-summary__list-item", /included not allowed type .sh/
    assert_select "input[type=file]"
  end

  view_test "POST :create with attachment metadata saves attachments to edition" do
    post :create, params: { edition_id: @edition, bulk_upload: valid_create_params }
    assert_response :redirect
    assert_equal 2, @edition.reload.attachments.count
    assert_equal @titles[0], @edition.attachments[0].title
    assert_equal @titles[1], @edition.attachments[1].title
  end

  view_test "POST :create with invalid attachments re-renders the bulk upload form" do
    post :create, params: { edition_id: @edition, bulk_upload: invalid_create_params }

    assert_response :success
    assert_select ".gem-c-error-summary__list-item", text: /simple.pdf: Title cannot be blank/
  end

  test "POST :create associates the attachment's attachment_data object with the edition" do
    post :create, params: { edition_id: @edition, bulk_upload: valid_create_params }

    bulk_upload = assigns(:bulk_upload)
    bulk_upload.attachments.each do |attachment|
      assert_equal @edition, attachment.attachment_data.attachable
    end
  end
end

require 'test_helper'

class Admin::BulkUploadsControllerTest < ActionController::TestCase
  setup do
    @edition = create(:news_article)
    login_as :gds_editor
    @titles = []
  end

  def params_for_attachment(attachment, i)
    file_cache = attachment.attachment_data.file_cache
    @titles << "Title #{i}"
    {
      title: @titles.last,
      attachment_data_attributes: { file_cache: file_cache }
    }
  end

  def valid_create_params
    fixture_file = fixture_file_upload('two-pages-and-greenpaper.zip')
    zip_file = BulkUpload::ZipFile.new(fixture_file)
    bulk_upload = BulkUpload.from_files(zip_file.extracted_file_paths)
    { attachments: [] }.tap do |params|
      bulk_upload.attachments.each_with_index do |attachment, i|
        params[:attachments] << params_for_attachment(attachment, i + 1)
      end
    end
  end

  def invalid_create_params
    valid_create_params.tap do |params|
      params[:attachments][0][:title] = ''
    end
  end

  def post_to_upload_zip(filename)
    post :upload_zip, edition_id: @edition, bulk_upload_zip_file: {
      zip_file: fixture_file_upload(filename)
    }
  end

  test 'Actions are unavailable on unmodifiable editions' do
    edition = create(:published_news_article)
    get :new, edition_id: edition
    assert_response :redirect
  end

  view_test 'GET :new displays a bulk upload form' do
    get :new, edition_id: @edition

    assert_response :success
    assert_select 'input[type=file]'
  end

  test 'bulk upload access is forbidden for users without access to the edition' do
    login_as :world_editor
    get :new, edition_id: @edition
    assert_response :forbidden
  end

  view_test 'POST :upload_zip prompts for metadata for each file in the zip' do
    post_to_upload_zip('two-pages-and-greenpaper.zip')
    assert_response :success
    assert_select 'li input[name*=title]', count: 2
    assert_select 'li', /two-pages.pdf/
    assert_select 'li', /greenpaper.pdf/
  end

  view_test 'POST :upload_zip lists errors and re-renders form when zip invalid' do
    post_to_upload_zip('whitepaper.pdf')
    assert_response :success
    assert_select '.errors', /not a zip file/
    assert_select 'input[type=file]'
  end

  view_test 'POST :upload_zip with illegal zip contents shows an error' do
    post_to_upload_zip('sample_attachment_containing_exe.zip')
    assert_response :success
    assert_select '.errors', /contains invalid files/
    assert_select 'input[type=file]'
  end

  view_test 'POST :create with attachment metadata saves attachments to edition' do
    post :create, edition_id: @edition, bulk_upload: valid_create_params

    assert_response :redirect
    assert_equal 2, @edition.reload.attachments.count
    assert_equal @titles[0], @edition.attachments[0].title
    assert_equal @titles[1], @edition.attachments[1].title
  end

  view_test 'POST :create with invalid attachments re-renders the bulk upload form' do
    post :create, edition_id: @edition, bulk_upload: invalid_create_params

    assert_response :success
    assert_select '.form-errors', text: /enter missing fields/
  end
end

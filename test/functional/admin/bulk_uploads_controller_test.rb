require 'test_helper'

class Admin::BulkUploadsControllerTest < ActionController::TestCase
  setup do
  	@edition = create(:news_article)
	  login_as :gds_editor
	end

	def valid_params
		bulk_upload = BulkUpload.from_files(BulkUpload::ZipFile.new(fixture_file_upload('two-pages-and-greenpaper.zip')).extracted_file_paths)
		file_cache1, file_cache2 = bulk_upload.attachments.map {|attachment| attachment.attachment_data.file_cache }
		{ attachments: [
			{ title: 'Title 1', attachment_data_attributes: { file_cache: file_cache1 } },
			{ title: 'Another title', attachment_data_attributes: { file_cache: file_cache2 } }
		]}
	end

	def invalid_params
		valid_params.tap do |params|
			params[:attachments][0][:title] = ''
		end
	end

	view_test 'GET :new displays a bulk upload form' do
		get :new, edition_id: @edition

		assert_response :success
		assert_select 'input[type=file]'
	end

	view_test 'POST :upload_zip prompts for titles for each attachment in the Zip file' do
		post :upload_zip, edition_id: @edition, bulk_upload_zip_file: { zip_file: fixture_file_upload('two-pages-and-greenpaper.zip') }

		assert_response :success
		assert_select 'li input[name*=title]', count: 2
		assert_select 'li', /two-pages.pdf/
		assert_select 'li', /greenpaper.pdf/
	end

	view_test 'POST :upload_zip lists errors and re-renders form when uploaded file is not valid' do
		post :upload_zip, edition_id: @edition, bulk_upload_zip_file: { zip_file: fixture_file_upload('whitepaper.pdf') }

		assert_response :success
		assert_select '.errors', /not a zip file/
		assert_select 'input[type=file]'
	end

	view_test 'POST :create with titles for attachments saves the attachments to the edition' do
		post :create, edition_id: @edition, bulk_upload: valid_params

    assert_response :redirect
    assert_equal 2, @edition.reload.attachments.count
    assert_equal 'Title 1', @edition.attachments[0].title
    assert_equal 'Another title', @edition.attachments[1].title
	end

	view_test 'POST :create with invalid attachments re-renders the bulk upload form' do
		post :create, edition_id: @edition, bulk_upload: invalid_params

		assert_response :success
		assert_select '.form-errors', text: /enter missing fields/
	end
end

require 'test_helper'

class Admin::BulkUploadsControllerTest < ActionController::TestCase
  setup do
  	@edition = create(:news_article)
	  login_as :gds_editor
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
end

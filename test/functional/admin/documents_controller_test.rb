require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class Admin::DocumentsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  def setup
    login_as :user
    @document = create(:edition, :with_document).document
    @url_maker = Whitehall::UrlMaker.new(host: Plek.find('whitehall'))
  end

  view_test 'GET by-content-id redirects to content by content_id' do
    get :by_content_id, content_id: @document.content_id
    assert_redirected_to @url_maker.admin_edition_path(@document.latest_edition)
  end

  view_test 'GET by-content-id redirects to a search if content_id is not found' do
    get :by_content_id, content_id: @document.content_id + "wrong-id"
    assert_redirected_to @url_maker.admin_editions_path
  end
end

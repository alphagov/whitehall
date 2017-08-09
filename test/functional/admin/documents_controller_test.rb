require 'test_helper'

class Admin::DocumentsControllerTest < ActionController::TestCase
  def setup
    login_as :user
    @document = create(:edition, :with_document).document
    @url_maker = Whitehall::UrlMaker.new(host: Plek.find('whitehall'))
  end

  view_test 'GET by-content-id redirects to content by content_id' do
    get :by_content_id, params: { content_id: @document.content_id }
    assert_redirected_to @url_maker.admin_edition_path(@document.latest_edition)
  end

  view_test 'GET by-content-id redirects to a search if content_id is not found' do
    get :by_content_id, params: { content_id: @document.content_id + "wrong-id" }
    assert_redirected_to @url_maker.admin_editions_path
  end
end

require 'test_helper'

class PublicationFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test 'json provides the atom feed url' do
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter, @view_context).to_json)
    assert_equal "http://test.host/government/publications.atom", json['atom_feed_url']
  end
end

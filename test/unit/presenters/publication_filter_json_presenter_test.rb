require 'test_helper'

class PublicationFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test 'json provides the atom feed url' do
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter, @view_context).to_json)
    assert_equal Whitehall.atom_feed_maker.publications_url, json['atom_feed_url']
  end

  test 'includes the category of documents being presented' do
    presenter = JSON.parse(
      PublicationFilterJsonPresenter.new(
        @filter, @view_context, PublicationesquePresenter
      ).to_json
    )

    assert_equal(
      'Publication',
      presenter['category'],
      'It should have a category attribute of "Publication"'
    )
  end
end

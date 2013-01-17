require 'test_helper'

class PublicationFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = stub_everything("Whitehall::DocumentFilter",
      count: 1,
      current_page: 1,
      num_pages: 1,
      documents: [])
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test 'json provides the atom feed url' do
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter).to_json)
    assert_equal "http://test.host/government/publications.atom", json['atom_feed_url']
  end

  test 'json document list includes publication_date and publication_type' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Silly", organisation_type: stub_record(:organisation_type))
    publication = stub_record("publication", document: document, organisations: [organisation], public_timestamp: Date.parse('2012-12-12').to_datetime)
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    publication.stubs(:organisations).returns([organisation])
    publication.stubs(:document_series).returns([stub_record(:document_series, name: "test-series", organisation: organisation)])
    @filter.stubs(:documents).returns(PublicationesquePresenter.decorate([publication]))
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter).to_json)
    assert_equal 1, json['results'].size
    assert_equal %{<abbr class="public_timestamp" title="2012-12-12T00:00:00+00:00">12 December 2012</abbr>}, json['results'].first["display_date_microformat"]
    assert_equal "Policy paper", json['results'].first["publication_type"]
  end
end

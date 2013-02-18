require 'test_helper'

class DocumentFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test "#to_json returns a serialized json representation" do
    presenter = DocumentFilterJsonPresenter.new(@filter)
    assert JSON.parse(presenter.to_json)
  end

  test 'json provides pagination info' do
    @filter.documents.stubs(:current_page).returns(2)
    @filter.documents.stubs(:count).returns(45)
    @filter.documents.stubs(:num_pages).returns(3)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).to_json)
    assert_equal 45, json['count']
    assert_equal 2, json['current_page']
    assert_equal 3, json['total_pages']
    assert_equal 3, json['next_page']
    assert_equal 1, json['prev_page']
    assert_equal "/government/publications?page=3", json['next_page_url']
    assert_equal "/government/publications?page=1", json['prev_page_url']
  end

  test 'next_page omitted if last page' do
    @filter.documents.stubs(:last_page?).returns(true)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).to_json)
    refute json.has_key?("next_page")
    refute json.has_key?("next_page_url")
  end

  test 'prev_page omitted if first page' do
    @filter.documents.stubs(:first_page?).returns(true)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).to_json)
    refute json.has_key?("prev_page")
    refute json.has_key?("prev_page_url")
  end

  test 'json provides a list of documents' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Silly", organisation_type: stub_record(:organisation_type))
    publication = stub_record("publication", document: document, organisations: [organisation], public_timestamp: 3.days.ago)
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    publication.stubs(:organisations).returns([organisation])
    @filter.stubs(:documents).returns(Kaminari.paginate_array([publication]).page(1))
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).to_json)
    assert_equal 1, json['results'].size
    assert_equal({
      "id" => publication.id,
      "type" => "publication",
      "title" => publication.title,
      "url" => "/government/publications/some-doc",
      "organisations" => "Ministry of Silly",
      "public_timestamp" => 3.days.ago.iso8601
      }, json['results'].first)
  end
end

require 'test_helper'

class DocumentFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = stub_everything("Whitehall::DocumentFilter",
      count: stub_everything,
      current_page: stub_everything,
      num_pages: stub_everything,
      documents: [])
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test "#json returns a serialized json representation" do
    presenter = DocumentFilterJsonPresenter.new(@filter)
    assert JSON.parse(presenter.json)
  end

  test '#json provides pagination info' do
    @filter.stubs(:current_page).returns(2)
    @filter.stubs(:count).returns(45)
    @filter.stubs(:num_pages).returns(3)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).json)
    assert_equal 45, json['count']
    assert_equal 2, json['current_page']
    assert_equal 3, json['total_pages']
    assert_equal 3, json['next_page']
    assert_equal 1, json['prev_page']
    assert_equal "/government/publications?page=3", json['next_page_url']
    assert_equal "/government/publications?page=1", json['prev_page_url']
  end

  test 'next_page omitted if last page' do
    @filter.stubs(:last_page?).returns(true)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).json)
    refute json.has_key?("next_page")
    refute json.has_key?("next_page_url")
  end

  test 'prev_page omitted if first page' do
    @filter.stubs(:first_page?).returns(true)
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).json)
    refute json.has_key?("prev_page")
    refute json.has_key?("prev_page_url")
  end

  test '#json provides a list of documents' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Silly", organisation_type: stub_record(:organisation_type))
    publication = stub_record("publication", document: document, organisations: [organisation])
    @filter.stubs(:documents).returns([publication])
    json = JSON.parse(DocumentFilterJsonPresenter.new(@filter).json)
    assert_equal 1, json['results'].size
    assert_equal({
      "id" => publication.id,
      "type" => "publication",
      "title" => publication.title,
      "url" => "/government/publications/some-doc",
      "organisations" => "Ministry of Silly"
      }, json['results'].first)
  end
end

class PublicationFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = stub_everything("Whitehall::DocumentFilter",
      count: stub_everything,
      current_page: stub_everything,
      num_pages: stub_everything,
      documents: [])
    self.params[:action] = :index
    self.params[:controller] = :publications
  end

  test '#json provides the atom feed url' do
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter).json)
    assert_equal "http://test.host/government/publications.atom", json['atom_feed_url']
  end

  test '#json document list includes publication_date and publication_type' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Silly", organisation_type: stub_record(:organisation_type))
    publication = stub_record("publication", document: document, organisations: [organisation])
    @filter.stubs(:documents).returns([publication])
    json = JSON.parse(PublicationFilterJsonPresenter.new(@filter).json)
    assert_equal 1, json['results'].size
    assert_equal "<abbr class=\"publication_date\" title=\"2011-11-01T11:11:11+00:00\">1 November 2011 11:11</abbr>", json['results'].first["publication_date"]
    assert_equal "Policy paper", json['results'].first["publication_type"]
  end
end

class SpecialistGuideFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = stub_everything("Whitehall::DocumentFilter",
      count: stub_everything,
      current_page: stub_everything,
      num_pages: stub_everything,
      documents: [])
    self.params[:action] = :index
    self.params[:controller] = :specialist_guides
  end

  test '#json document list includes topics' do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    topic = stub_record(:topic, name: "Tax")
    specialist_guide = stub_record(:specialist_guide, document: document, organisations: [], topics: [topic])
    @filter.stubs(:documents).returns([specialist_guide])
    json = JSON.parse(SpecialistGuideFilterJsonPresenter.new(@filter).json)
    assert_equal 1, json['results'].size
  end
end

require 'test_helper'

class DocumentFilterPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    @view_context.params[:action] = :index
    @view_context.params[:controller] = :publications
    @view_context.params[:format] = :json
  end

  def stub_publication
    @stub_publication ||= begin
      stub_document = stub_record(:document)
      stub_document.stubs(:to_param).returns('some-doc')
      organisation = stub_record(:organisation, name: "Ministry of Silly")
      publication = stub_record(
        "publication",
        document: stub_document,
        attachments: [],
        organisations: [organisation],
        public_timestamp: 3.days.ago.as_json
      )
      government = Government.new
      publication.stubs(:government).returns(government)
      # TODO: perhaps rethink edition factory, so this apparent duplication
      # isn't neccessary
      publication.stubs(:organisations).returns([organisation])
      publication.stubs(:published_document_collections).returns([])
      publication
    end
  end

  test "#to_json returns a serialized json representation" do
    presenter = DocumentFilterPresenter.new(@filter, @view_context)
    assert JSON.parse(presenter.to_json)
  end

  test 'json provides pagination info' do
    @filter.documents.stubs(:current_page).returns(2)
    @filter.documents.stubs(:count).returns(45)
    @filter.documents.stubs(:total_pages).returns(3)
    json = JSON.parse(DocumentFilterPresenter.new(@filter, @view_context).to_json)
    assert_equal 45, json['count']
    assert_equal 2, json['current_page']
    assert_equal 3, json['total_pages']
    assert_equal 3, json['next_page']
    assert_equal 1, json['prev_page']
    assert_equal "/government/publications.json?page=3", json['next_page_url']
    assert_equal "/government/publications.json?page=1", json['prev_page_url']
    assert_equal "/government/publications?page=3", json['next_page_web_url']
    assert_equal "/government/publications?page=1", json['prev_page_web_url']
  end

  test 'next_page omitted if last page' do
    @filter.documents.stubs(:last_page?).returns(true)
    json = JSON.parse(DocumentFilterPresenter.new(@filter, @view_context).to_json)
    assert_not json.has_key?("next_page")
    assert_not json.has_key?("next_page_url")
    assert_not json.has_key?("next_page_web_url")
  end

  test 'prev_page omitted if first page' do
    @filter.documents.stubs(:first_page?).returns(true)
    json = JSON.parse(DocumentFilterPresenter.new(@filter, @view_context).to_json)
    assert_not json.has_key?("prev_page")
    assert_not json.has_key?("prev_page_url")
    assert_not json.has_key?("prev_page_web_url")
  end

  test 'json provides a list of documents with their positions' do
    presenters = [PublicationesquePresenter.new(stub_publication, @view_context)]
    @filter.stubs(:documents).returns(Kaminari.paginate_array(presenters).page(1))
    json = JSON.parse(DocumentFilterPresenter.new(@filter, @view_context).to_json)
    assert_equal 1, json['results'].size
    expected_result = {
      'result' => {
        "id" => stub_publication.id,
        "type" => "publication",
        "display_type" => "Policy paper",
        "title" => stub_publication.title,
        "url" => "/government/publications/some-doc",
        "organisations" => "Ministry of Silly",
        "display_date_microformat" => "<time class=\"public_timestamp\" datetime=\"2011-11-08T11:11:11+00:00\"> 8 November 2011</time>",
        "public_timestamp" => 3.days.ago.as_json,
        "historic?" => false,
        "government_name" => nil,
        "publication_collections" => nil,
      },
      'index' => 1,
    }

    assert_equal(expected_result, json['results'].first)
  end

  test 'decorates each documents with the given decorator class' do
    MyDecorator = Struct.new(:model, :context)

    stub_document = stub(:document)
    @filter.stubs(:documents).returns(Kaminari.paginate_array([stub_document]).page(1))

    presenter = DocumentFilterPresenter.new(@filter, @view_context, MyDecorator)
    assert_instance_of Whitehall::Decorators::CollectionDecorator, presenter.documents
    assert_instance_of MyDecorator, presenter.documents.first
    assert_equal stub_document, presenter.documents.first.model
    assert_equal @view_context, presenter.documents.first.context
  end

  test 'includes the category of documents being presented' do
    json = JSON.parse(DocumentFilterPresenter.new(@filter, @view_context).to_json)

    assert_equal(
      'Document',
      json['category'],
      'It should have a category attribute of "Document"'
    )
  end
end

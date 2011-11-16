module TestsForCountries
  extend ActiveSupport::Testing::Declarative

  test 'new displays document form with countries field' do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name*='document[country_ids]']"
    end
  end

  test 'creating should create a new news article with countries' do
    first_country = create(:country)
    second_country = create(:country)
    attributes = attributes_for_document

    post :create, document: attributes.merge(
      country_ids: [first_country.id, second_country.id]
    )

    assert document = document_class.last
    assert_equal [first_country, second_country], document.countries
  end

  test 'updating should save modified document attributes with countries' do
    first_country = create(:country)
    second_country = create(:country)
    document = create_document(countries: [first_country])

    put :update, id: document, document: {
      country_ids: [second_country.id]
    }

    document = document.reload
    assert_equal [second_country], document.countries
  end

  test 'updating should remove all countries if none in params' do
    country = create(:country)

    document = create_document(countries: [country])

    put :update, id: document, document: {}

    document.reload
    assert_equal [], document.countries
  end

  test 'updating a stale document should render edit page with conflicting document and its countries' do
    document = create_document
    lock_version = document.lock_version
    document.touch

    put :update, id: document, document: document.attributes.merge(lock_version: lock_version)

    assert_select ".document.conflict" do
      assert_select "h1", "Countries"
    end
  end

  test "should display the countries to which the document relates" do
    first_country = create(:country)
    second_country = create(:country)
    document = create_document(countries: [first_country, second_country])

    get :show, id: document

    assert_select_object(first_country)
    assert_select_object(second_country)
  end

  test "should indicate that the document does not relate to any country" do
    document = create_document(countries: [])

    get :show, id: document

    assert_select "p", "This document isn't assigned to any countries."
  end

  private

  def attributes_for_document(attributes = {})
    attributes_for(document_class.name.underscore, attributes)
  end

  def create_document(attributes = {})
    create(document_class.name.underscore, attributes)
  end

  def document_class
    Document
  end
end
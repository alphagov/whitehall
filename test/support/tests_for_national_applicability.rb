require 'support/nation_applicability_assertions'

module TestsForNationalApplicability
  extend ActiveSupport::Testing::Declarative
  include NationApplicabilityAssertions

  test "new displays document form with nation inapplicability fields" do
    get :new

    assert_select "form#document_new" do
      assert_nation_inapplicability_fields_exist
    end
  end

  test 'create should create a new document with nation inapplicabilities' do
    attributes = attributes_for_document

    post :create, document: attributes.merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

    assert document = Edition.last
    assert scotland_inapplicability = document.nation_inapplicabilities.for_nation(Nation.scotland).first
    assert_equal "http://www.scotland.com/", scotland_inapplicability.alternative_url
  end

  test 'creating with invalid document data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_document
    post :create, document: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
    assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
  end

  test 'creating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_document
    post :create, document: attributes.merge(
      nation_inapplicabilities_attributes_for(Nation.scotland => "invalid-url")
    )

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "invalid-url")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
    assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
  end

  test 'edit displays document form with nation inapplicability fields and values' do
    document = create_document
    northern_ireland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    get :edit, id: document

    assert_select "form#document_edit" do
      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.discovernorthernireland.com/")
    end
  end

  test 'updating should save modified document with nation inapplicabilities' do
    attributes = attributes_for_document
    document = create_document(attributes)
    northern_ireland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    put :update, id: document, document: attributes.merge(
      nation_inapplicabilities_attributes_for({Nation.scotland => "http://www.visitscotland.com/"}, northern_ireland_inapplicability)
    )

    document.reload
    assert_equal [Nation.scotland], document.inapplicable_nations
    assert_equal "http://www.visitscotland.com/", document.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
  end

  test 'updating with invalid document data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_document
    document = create_document(attributes)
    scotland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

    put :update, id: document, document: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  test 'updating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_document
    document = create_document(attributes)
    scotland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

    put :update, id: document, document: attributes.merge(
      nation_inapplicabilities_attributes_for(
        {Nation.northern_ireland => "invalid-url"},
        scotland_inapplicability,
        wales_inapplicability
    ))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "invalid-url")
  end

  test 'updating a stale document should not lose the nation inapplicability fields or values' do
    document = create_document
    scotland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")
    lock_version = document.lock_version
    document.update_attributes!(title: "new title")

    put :update, id: document, document: document.attributes.merge(
      lock_version: lock_version
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  test "show lists nation inapplicabilities when there are some" do
    document = create_document
    scotland_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://scotland.com/")
    wales_inapplicability = document.nation_inapplicabilities.create!(nation: Nation.wales)

    get :show, id: document

    assert_select ".nation_inapplicabilities" do
      assert_select_object scotland_inapplicability, text: /Scotland/ do
        assert_select ".alternative_url a[href='http://scotland.com/']"
      end
      assert_select_object wales_inapplicability, text: /Wales/ do
        refute_select ".alternative_url a"
      end
    end
  end

  test "show explains the document applies to all nations of the UK" do
    document = create_document

    get :show, id: document

    assert_select "p", "This document applies to the whole of the UK."
  end

  private

  def attributes_for_document(attributes = {})
    attributes_for(document_class.name.underscore, attributes)
  end

  def create_document(attributes = {})
    create(document_class.name.underscore, attributes)
  end

  def document_class
    Edition
  end
end
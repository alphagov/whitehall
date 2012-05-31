require 'support/nation_applicability_assertions'

module TestsForNationalApplicability
  extend ActiveSupport::Testing::Declarative
  include NationApplicabilityAssertions

  test "new displays edition form with nation inapplicability fields" do
    get :new

    assert_select "form#edition_new" do
      assert_nation_inapplicability_fields_exist
    end
  end

  test 'create should create a new edition with nation inapplicabilities' do
    attributes = attributes_for_edition

    post :create, edition: attributes.merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

    assert edition = Edition.last
    assert scotland_inapplicability = edition.nation_inapplicabilities.for_nation(Nation.scotland).first
    assert_equal "http://www.scotland.com/", scotland_inapplicability.alternative_url
  end

  test 'creating with invalid edition data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_edition
    post :create, edition: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
    assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
  end

  test 'creating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_edition
    post :create, edition: attributes.merge(
      nation_inapplicabilities_attributes_for(Nation.scotland => "invalid-url")
    )

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "invalid-url")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
    assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
  end

  test 'edit displays edition form with nation inapplicability fields and values' do
    edition = create_edition
    northern_ireland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    get :edit, id: edition

    assert_select "form#edition_edit" do
      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.discovernorthernireland.com/")
    end
  end

  test 'updating should save modified edition with nation inapplicabilities' do
    attributes = attributes_for_edition
    edition = create_edition(attributes)
    northern_ireland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    put :update, id: edition, edition: attributes.merge(
      nation_inapplicabilities_attributes_for({Nation.scotland => "http://www.visitscotland.com/"}, northern_ireland_inapplicability)
    )

    edition.reload
    assert_equal [Nation.scotland], edition.inapplicable_nations
    assert_equal "http://www.visitscotland.com/", edition.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
  end

  test 'updating with invalid edition data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_edition
    edition = create_edition(attributes)
    scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

    put :update, id: edition, edition: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  test 'updating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
    attributes = attributes_for_edition
    edition = create_edition(attributes)
    scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

    put :update, id: edition, edition: attributes.merge(
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

  test 'updating a stale edition should not lose the nation inapplicability fields or values' do
    edition = create_edition
    scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")
    lock_version = edition.lock_version
    edition.update_attributes!(title: "new title")

    put :update, id: edition, edition: edition.attributes.merge(
      lock_version: lock_version
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
    assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  test "show lists nation inapplicabilities when there are some" do
    edition = create_edition
    scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://scotland.com/")
    wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales)

    get :show, id: edition

    assert_select ".nation_inapplicabilities" do
      assert_select_object scotland_inapplicability, text: /Scotland/ do
        assert_select ".alternative_url a[href='http://scotland.com/']"
      end
      assert_select_object wales_inapplicability, text: /Wales/ do
        refute_select ".alternative_url a"
      end
    end
  end

  test "show explains the edition applies to all nations of the UK" do
    edition = create_edition

    get :show, id: edition

    assert_select "p", "This document applies to the whole of the UK."
  end

  private

  def attributes_for_edition(attributes = {})
    attributes_for(edition_class.name.underscore, attributes)
  end

  def create_edition(attributes = {})
    create(edition_class.name.underscore, attributes)
  end

  def edition_class
    Edition
  end
end
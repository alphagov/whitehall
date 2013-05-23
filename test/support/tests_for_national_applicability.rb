module TestsForNationalApplicability
  extend ActiveSupport::Concern

  included do
    view_test "new displays edition form with nation inapplicability fields" do
      get :new

      assert_select "form#new_edition" do
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

    view_test 'creating with invalid edition data should not lose the nation inapplicability fields or values' do
      attributes = attributes_for_edition
      post :create, edition: attributes.merge(
        title: ''
      ).merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "http://www.scotland.com/")
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
    end

    view_test 'creating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
      attributes = attributes_for_edition
      post :create, edition: attributes.merge(
        nation_inapplicabilities_attributes_for(Nation.scotland => "invalid-url")
      )

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "invalid-url")
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
    end

    view_test 'edit displays edition form with nation inapplicability fields and values' do
      edition = create_edition
      northern_ireland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

      get :edit, id: edition

      assert_select "form#edit_edition" do
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

      put :update, id: edition, edition: controller_attributes_for_instance(edition,
        nation_inapplicabilities_attributes_for({Nation.scotland => "http://www.visitscotland.com/"}, northern_ireland_inapplicability)
      )

      edition.reload
      assert_equal [Nation.scotland], edition.inapplicable_nations
      assert_equal "http://www.visitscotland.com/", edition.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
    end

    view_test 'updating with invalid edition data should not lose the nation inapplicability fields or values' do
      attributes = attributes_for_edition
      edition = create_edition(attributes)
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

      put :update, id: edition, edition: controller_attributes_for_instance(edition,
        {title: ''}.merge(
          nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability)
        )
      )

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
    end

    view_test 'updating with invalid nation inapplicability data should not lose the nation inapplicability fields or values' do
      attributes = attributes_for_edition
      edition = create_edition(attributes)
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

      put :update, id: edition, edition: controller_attributes_for_instance(edition,
        nation_inapplicabilities_attributes_for(
          {Nation.northern_ireland => "invalid-url"},
          scotland_inapplicability,
          wales_inapplicability
        )
      )

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "invalid-url")
    end

    view_test 'updating a stale edition should not lose the nation inapplicability fields or values' do
      edition = create_edition
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")
      lock_version = edition.lock_version
      edition.update_attributes!(title: "new title")

      put :update, id: edition, edition: controller_attributes_for_instance(edition,
        {lock_version: lock_version}.merge(
          nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability)
        )
      )

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false, alternative_url: "http://www.scotland.com/")
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.wales.com/")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
    end

    view_test "show lists nation inapplicabilities when there are some" do
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

    view_test "show explains the edition applies to all nations of the UK" do
      edition = create_edition

      get :show, id: edition

      assert_select "p", "This document applies to the whole of the UK."
    end
  end
  private

  def attributes_for_edition(attributes = {})
    controller_attributes_for(edition_class.name.underscore, attributes)
  end

  def create_edition(attributes = {})
    create(edition_class.name.underscore, attributes)
  end

  def edition_class
    Edition
  end

  def assert_nation_inapplicability_fields_exist
    n = Nation.potentially_inapplicable.count
    assert_select "input[name*='edition[nation_inapplicabilities_attributes]'][type='checkbox']", count: n
    assert_select "input[name*='edition[nation_inapplicabilities_attributes]'][type='text']", count: n
  end

  def nation_inapplicabilities_attributes_for(nations_vs_urls, *existing_applicabilities)
    result = {}
    [Nation.scotland, Nation.wales, Nation.northern_ireland].each.with_index do |nation, index|
      h = result[index.to_s] = {
        _destroy: (nations_vs_urls.keys.include?(nation) ? "0" : "1"),
        nation_id: nation
      }
      if existing = existing_applicabilities.detect { |ea| ea.nation_id == nation.id }
        h.merge!(id: existing.id, alternative_url: existing.alternative_url)
      end
      if nations_vs_urls[nation]
        h.merge!(alternative_url: nations_vs_urls[nation])
      end
    end
    {nation_inapplicabilities_attributes: result}
  end

  def assert_nation_inapplicability_fields_set_as(attributes)
    name_fragment = "edition[nation_inapplicabilities_attributes][#{attributes[:index]}]"
    if attributes[:checked]
      assert_select "input[name='#{name_fragment}[_destroy]'][type='checkbox'][checked='checked']"
    else
      refute_select "input[name='#{name_fragment}[_destroy]'][type='checkbox'][checked='checked']"
      assert_select "input[name='#{name_fragment}[_destroy]'][type='checkbox']"
    end
    if attributes[:alternative_url]
      assert_select "input[name='#{name_fragment}[alternative_url]'][value='#{attributes[:alternative_url]}']"
    end
  end
end

module TestsForNationalApplicability
  extend ActiveSupport::Concern

  included do
    view_test "new displays edition form with nation inapplicability fields" do
      get :new

      assert_select "form#new_edition" do
        assert_nation_inapplicability_fields_exist
      end
    end

    test "create should create a new edition with nation inapplicabilities" do
      create(:government)
      attributes = attributes_for_edition(all_nation_applicability: "0")

      post :create, params: { edition: attributes.merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.example.com/scotland")) }

      assert edition = Edition.last
      assert scotland_inapplicability = edition.nation_inapplicabilities.for_nation(Nation.scotland).first
      assert_equal "http://www.example.com/scotland", scotland_inapplicability.alternative_url
    end

    test "create should create a new edition with all_nation_applicability including all nations" do
      create(:government)

      post :create, params: { edition: attributes_for_edition }

      assert edition = Edition.last
      assert_equal edition.national_applicability, expected_national_applicability
    end

    test "create should create a new edition with all_nation_applicability overriding individual options" do
      create(:government)

      post :create, params: { edition: attributes_for_edition }

      assert edition = Edition.last
      assert_equal edition.national_applicability, expected_national_applicability
    end

    test "national_applicability works correctly" do
      scotland_nation_inapplicability = create(
        :nation_inapplicability,
        nation: Nation.scotland,
        alternative_url: "http://www.example.com/scotland",
      )
      detailed_guide = create(
        :published_detailed_guide_with_excluded_nations,
        nation_inapplicabilities: [
          scotland_nation_inapplicability,
        ],
      )

      national_applicability_excluding_scotland = expected_national_applicability.merge(
        scotland: {
          label: "Scotland",
          applicable: false,
          alternative_url: "http://www.example.com/scotland",
        },
      )

      assert_equal detailed_guide.national_applicability, national_applicability_excluding_scotland
    end

    view_test "creating with all nations excluded should fail validation" do
      create(:government)
      attributes = attributes_for_edition(all_nation_applicability: "0")

      all_nations = nation_inapplicabilities_attributes_for({
        Nation.england => "http://www.example.com/england.",
        Nation.scotland => "http://www.example.com/scotland",
        Nation.wales => "http://www.example.com/wales",
        Nation.northern_ireland => "http://www.example.com/ni",
      })

      post :create, params: { edition: attributes.merge(all_nations) }

      assert_nil Edition.last

      assert_page_has_error("Excluded nations can not exclude all nations")
    end

    view_test "creating with no applicability options should fail validation" do
      create(:government)

      post :create, params: { edition: attributes_for_edition(all_nation_applicability: "0") }

      assert_nil Edition.last

      assert_page_has_error("Excluded nations - you must select whether this content applies to all UK nations or which ones it excludes")
    end

    view_test "creating with all_nation_applicability and an excluded nation should fail validation" do
      create(:government)

      post :create, params: {
        edition: attributes_for_edition.merge(
          nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.example.com/scotland"),
          all_nation_applicability: "1",
        ),
      }

      assert_page_has_error("Excluded nations - you cannot select all UK nations and also exclude nations")
    end

    view_test "creating with invalid edition data should not lose the nation inapplicability fields or values" do
      attributes = attributes_for_edition(all_nation_applicability: "0")
      post :create,
           params: {
             edition: attributes.merge(
               title: "",
             ).merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.example.com/scotland")),
           }

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: true, alternative_url: "http://www.example.com/scotland")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 3, checked: false)
    end

    view_test "creating with invalid nation inapplicability data should not lose the nation inapplicability fields or values" do
      attributes = attributes_for_edition(all_nation_applicability: "0")
      post :create,
           params: {
             edition: attributes.merge(
               nation_inapplicabilities_attributes_for(Nation.scotland => "invalid-url"),
             ),
           }

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: true, alternative_url: "invalid-url")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 3, checked: false)
    end

    view_test "edit displays edition form with nation inapplicability fields and values" do
      edition = create_edition(all_nation_applicability: "1")
      edition.update_column(:all_nation_applicability, false)
      edition.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.example.com/ni")

      get :edit, params: { id: edition }

      assert_select "form#edit_edition" do
        assert_nation_inapplicability_fields_exist
        assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
        assert_nation_inapplicability_fields_set_as(index: 1, checked: false)
        assert_nation_inapplicability_fields_set_as(index: 2, checked: false)
        assert_nation_inapplicability_fields_set_as(index: 3, checked: true, alternative_url: "http://www.example.com/ni")
      end
    end

    test "updating should save modified edition with nation inapplicabilities" do
      edition = create_edition(all_nation_applicability: "1")
      edition.update_column(:all_nation_applicability, false)
      northern_ireland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.example.com/ni")
      edition.save!

      assert_equal [Nation.northern_ireland], edition.inapplicable_nations
      assert_equal "http://www.example.com/ni", edition.nation_inapplicabilities.for_nation(Nation.northern_ireland).first.alternative_url

      put :update, params: { id: edition, edition: nation_inapplicabilities_attributes_for({ Nation.scotland => "http://www.example.com/scotland" }, northern_ireland_inapplicability) }

      edition.reload
      assert_equal [Nation.scotland], edition.inapplicable_nations
      assert_equal "http://www.example.com/scotland", edition.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
    end

    view_test "updating with invalid edition data should not lose the nation inapplicability fields or values" do
      edition = create_edition(all_nation_applicability: "1")
      edition.update_column(:all_nation_applicability, false)
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.example.com/scotland")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.example.com/wales")
      edition.save!

      attributes = nation_inapplicabilities_attributes_for({ Nation.northern_ireland => "http://www.example.com/ni" }, scotland_inapplicability, wales_inapplicability).merge(title: "")

      put :update, params: { id: edition, edition: attributes }

      assert_page_has_error("Title can't be blank")

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.example.com/scotland")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false, alternative_url: "http://www.example.com/wales")
      assert_nation_inapplicability_fields_set_as(index: 3, checked: true, alternative_url: "http://www.example.com/ni")
    end

    view_test "updating with invalid nation inapplicability data should not lose the nation inapplicability fields or values" do
      edition = create_edition(all_nation_applicability: "1")
      edition.update_column(:all_nation_applicability, false)
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.example.com/scotland")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.example.com/wales")
      edition.save!

      put :update,
          params: { id: edition,
                    edition: nation_inapplicabilities_attributes_for(
                      { Nation.northern_ireland => "invalid-url" },
                      scotland_inapplicability,
                      wales_inapplicability,
                    ) }

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.example.com/scotland")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false, alternative_url: "http://www.example.com/wales")
      assert_nation_inapplicability_fields_set_as(index: 3, checked: true, alternative_url: "invalid-url")
    end

    view_test "updating a stale edition should not lose the nation inapplicability fields or values" do
      edition = create_edition(all_nation_applicability: "1")
      edition.update_column(:all_nation_applicability, false)
      scotland_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.example.com/scotland")
      wales_inapplicability = edition.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.example.com/wales")

      lock_version = edition.lock_version
      edition.update!(title: "new title", change_note: "foo")

      stale_attributes = nation_inapplicabilities_attributes_for({ Nation.northern_ireland => "http://www.example.com/ni" }, scotland_inapplicability, wales_inapplicability).merge(lock_version: lock_version)

      put :update, params: { id: edition, edition: stale_attributes }

      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 0, checked: false)
      assert_nation_inapplicability_fields_set_as(index: 1, checked: false, alternative_url: "http://www.example.com/scotland")
      assert_nation_inapplicability_fields_set_as(index: 2, checked: false, alternative_url: "http://www.example.com/wales")
      assert_nation_inapplicability_fields_set_as(index: 3, checked: true, alternative_url: "http://www.example.com/ni")
    end
  end

private

  def expected_national_applicability
    {
      england: {
        label: "England",
        applicable: true,
      },
      northern_ireland: {
        label: "Northern Ireland",
        applicable: true,
      },
      scotland: {
        label: "Scotland",
        applicable: true,
      },
      wales: {
        label: "Wales",
        applicable: true,
      },
    }
  end

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
    assert_select "input[name*='edition[all_nation_applicability]'][type='checkbox']", count: 1
    assert_select "input[name*='edition[nation_inapplicabilities_attributes]'][type='checkbox']", count: n
    assert_select "input[name*='edition[nation_inapplicabilities_attributes]'][type='text']", count: n
  end

  def nation_inapplicabilities_attributes_for(nations_vs_urls, *existing_applicabilities)
    result = {}
    [Nation.england, Nation.scotland, Nation.wales, Nation.northern_ireland].each.with_index do |nation, index|
      h = result[index.to_s] = {
        excluded: (nations_vs_urls.key?(nation) ? "1" : "0"),
        nation_id: nation,
      }
      if (existing = existing_applicabilities.detect { |ea| ea.nation_id == nation.id })
        h[:id] = existing.id
        h[:alternative_url] = existing.alternative_url
      end
      if nations_vs_urls[nation]
        h.merge!(alternative_url: nations_vs_urls[nation])
      end
    end
    { nation_inapplicabilities_attributes: result }
  end

  def assert_page_has_error(error)
    assert_select(".errors", text: error)
  end

  def assert_nation_inapplicability_fields_set_as(attributes)
    name_fragment = "edition[nation_inapplicabilities_attributes][#{attributes[:index]}]"
    if attributes[:checked]
      assert_select "input[name='#{name_fragment}[excluded]'][type='checkbox'][checked='checked']"
    else
      refute_select "input[name='#{name_fragment}[excluded]'][type='checkbox'][checked='checked']"
      assert_select "input[name='#{name_fragment}[excluded]'][type='checkbox']"
    end
    if attributes[:alternative_url]
      assert_select "input[name='#{name_fragment}[alternative_url]'][value='#{attributes[:alternative_url]}']"
    end
  end
end

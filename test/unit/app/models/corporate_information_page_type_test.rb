require "test_helper"

class CorporateInformationPageTypeTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation, name: "Department of Alphabet")
    @corporate_information_page_type = CorporateInformationPageType.new(
      id: 7, slug: "procurement", menu_heading: :jobs_and_contracts,
    )
  end

  test ".title uses the organisation's acronym when it exists" do
    @organisation.acronym = "ABC"
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation,
    )

    assert_equal "Procurement at ABC", corporate_information_page.title
  end

  test ".title uses the organisation's name when the acronym is nil" do
    @organisation.acronym = nil
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation,
    )

    assert_equal "Procurement at Department of Alphabet", corporate_information_page.title
  end

  test ".title_lang returns lang=en if the title translation does not exist" do
    @organisation.acronym = ""
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation,
    )

    I18n.stubs(:t)
      .with("corporate_information_page.type.title.#{corporate_information_page.slug}", anything)
      .returns("fallback")

    I18n.with_locale(:de) do
      assert_equal "lang=en", corporate_information_page.title_lang
    end
  end

  test ".title uses the organisation's name when the acronym is empty" do
    @organisation.acronym = ""
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation,
    )

    assert_equal "Procurement at Department of Alphabet", corporate_information_page.title
  end

  test ".for returns all corporate information types for organisations" do
    organisation = build(:organisation)

    assert_includes CorporateInformationPageType.for(organisation).map(&:slug), "about"
    assert_includes CorporateInformationPageType.for(organisation).map(&:id), 20
  end

  test ".for returns all corporate information types for editionable worldwide organisations" do
    organisation = build(:editionable_worldwide_organisation)

    assert_not_includes CorporateInformationPageType.for(organisation).map(&:slug), "about"
    assert_not_includes CorporateInformationPageType.for(organisation).map(&:id), 20
  end
end

require 'test_helper'

class CorporateInformationPageTypeTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation, name: 'Department of Alphabet')
    @corporate_information_page_type = CorporateInformationPageType.new(
      id: 7, slug: "procurement", menu_heading: :jobs_and_contracts
    )
  end

  test '.title uses the organisation\'s acronym when it exists' do
    @organisation.acronym = 'ABC'
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation
    )

    assert_equal "Procurement at ABC", corporate_information_page.title
  end

  test '.title uses the organisation\'s name when the acronym is nil' do
    @organisation.acronym = nil
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation
    )

    assert_equal "Procurement at Department of Alphabet", corporate_information_page.title
  end

  test '.title uses the organisation\'s name when the acronym is empty' do
    @organisation.acronym = ''
    corporate_information_page = create(
      :corporate_information_page,
      corporate_information_page_type: @corporate_information_page_type,
      organisation: @organisation
    )

    assert_equal "Procurement at Department of Alphabet", corporate_information_page.title
  end
end

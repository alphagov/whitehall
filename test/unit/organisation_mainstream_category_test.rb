require 'test_helper'

class OrganisationMainstreamCategoryTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation)
    @mainstream_category = create(:mainstream_category)
  end

  test 'it is invalid without an organisation' do
    refute build(:organisation_mainstream_category, organisation: nil).valid?
  end

  test 'it is invalid without a mainstream category' do
    refute build(:organisation_mainstream_category, mainstream_category: nil).valid?
  end

  test 'it is invalid without an ordering' do
    refute build(:organisation_mainstream_category, ordering: nil).valid?
  end

  test 'it is invalid if the organisation already has that mainstream category' do
    existing = create(:organisation_mainstream_category, mainstream_category: @mainstream_category, organisation: @organisation)
    refute build(:organisation_mainstream_category, mainstream_category: @mainstream_category, organisation: @organisation).valid?
  end
end

require 'test_helper'

class Edition::CanApplyToLocalGovernmentThroughRelatedPoliciesTest < ActiveSupport::TestCase
  class EditionWhichCanBeApplied < Edition
    include ::Edition::RelatedPolicies
    include ::Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    o = create(:organisation)
    {
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: build(:user),
      lead_organisations: [o]
    }
  end

  setup do
    @edition = EditionWhichCanBeApplied.new(valid_edition_attributes)
  end

  test "edition can be applied to local government" do
    assert @edition.can_apply_to_local_government?
  end

  test "edition obtains relevance to local government from any policy that is also relevant" do
    relevant_policy = build(:policy, relevant_to_local_government: true)
    irrelevant_policy = build(:policy, relevant_to_local_government: false)

    @edition.related_policies = [irrelevant_policy]
    refute @edition.relevant_to_local_government?

    @edition.related_policies = [relevant_policy, irrelevant_policy]
    assert @edition.relevant_to_local_government?
  end
end

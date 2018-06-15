require 'test_helper'

class Edition::CanApplyToLocalGovernmentThroughRelatedPoliciesTest < ActiveSupport::TestCase
  class EditionWhichCanBeApplied < Edition
    include ::Edition::RelatedPolicies
    include ::Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: build(:user),
      previously_published: false,
    }
  end

  setup do
    @edition = EditionWhichCanBeApplied.new(valid_edition_attributes)
  end

  test "edition can be applied to local government" do
    assert @edition.can_apply_to_local_government?
  end

  test "database value for relevant_to_local_government is ignored" do
    irrelevant_publication = build(:published_publication, relevant_to_local_government: true)
    irrelevant_publication.policy_content_ids = []

    refute irrelevant_publication.relevant_to_local_government?
  end

  test "edition obtains relevance to local government from new policies" do
    relevant_published_policy = policy_relevant_to_local_government
    irrelevant_policy = policy_1

    @edition.policy_content_ids = [irrelevant_policy["content_id"]]
    @edition.save!; @edition.reload
    refute @edition.relevant_to_local_government?

    @edition.policy_content_ids = [relevant_published_policy["content_id"], irrelevant_policy["content_id"]]
    @edition.save!; @edition.reload
    assert @edition.relevant_to_local_government?
  end
end

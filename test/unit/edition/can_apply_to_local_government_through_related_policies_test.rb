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
      creator: build(:user)
    }
  end

  setup do
    @edition = EditionWhichCanBeApplied.new(valid_edition_attributes)
  end

  test "edition can be applied to local government" do
    assert @edition.can_apply_to_local_government?
  end

  test "edition obtains relevance to local government from any published policy that is also relevant" do
    relevant_draft_policy = create(:policy, :with_document, relevant_to_local_government: true)
    relevant_published_policy = create(:published_policy, :with_document, relevant_to_local_government: true)
    irrelevant_policy = create(:published_policy, :with_document, relevant_to_local_government: false)

    @edition.related_editions = [irrelevant_policy]
    @edition.save!; @edition.reload
    refute @edition.relevant_to_local_government?

    @edition.related_editions = [relevant_draft_policy, irrelevant_policy]
    @edition.save!; @edition.reload
    refute @edition.relevant_to_local_government?

    @edition.related_editions = [relevant_published_policy, relevant_draft_policy, irrelevant_policy]
    @edition.save!; @edition.reload
    assert @edition.relevant_to_local_government?
  end

  test "database value for relevant_to_local_government is ignored" do
    irrelevant_publication = build(:published_publication, relevant_to_local_government: true)

    refute irrelevant_publication.relevant_to_local_government?
  end
end

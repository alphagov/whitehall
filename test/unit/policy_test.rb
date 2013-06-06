require "test_helper"

class PolicyTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :body

  test "does not allow attachment" do
    refute build(:policy).allows_attachments?
  end

  test "should be invalid without an alternative format provider" do
    refute build(:policy, alternative_format_provider: nil).valid?
  end

  test "should build a draft copy of the existing policy with inapplicable nations" do
    published_policy = create(:published_policy, nation_inapplicabilities_attributes: [
      {nation: Nation.wales, alternative_url: "http://wales.gov.uk"},
      {nation: Nation.scotland, alternative_url: "http://scot.gov.uk"}]
    )

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal published_policy.inapplicable_nations, draft_policy.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.scotland.id).alternative_url
  end

  test "should build a draft copy with references to related editions" do
    published_policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [published_policy])
    speech = create(:published_speech, related_editions: [published_policy])

    draft_policy = published_policy.create_draft(create(:policy_writer))
    draft_policy.change_note = 'change-note'
    assert draft_policy.valid?

    assert draft_policy.related_editions.include?(speech)
    assert draft_policy.related_editions.include?(publication)
  end

  test "should build a draft copy with policy groups" do
    published_policy = create(:published_policy)
    policy_team = create(:policy_team, policies: [published_policy])
    policy_advisory_group = create(:policy_advisory_group, policies: [published_policy])

    assert published_policy.policy_teams.include?(policy_team)
    assert published_policy.policy_advisory_groups.include?(policy_advisory_group)

    draft_policy = published_policy.create_draft(create(:policy_writer))
    draft_policy.change_note = 'change-note'
    assert draft_policy.valid?

    assert draft_policy.policy_teams.include?(policy_team)
    assert draft_policy.policy_advisory_groups.include?(policy_advisory_group)
  end

  test "can belong to multiple topics" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    policy = create(:policy, topics: [topic_1, topic_2])
    assert_equal [topic_1, topic_2], policy.topics.reload
  end

  test "#destroy should remove edition relations to other editions" do
    edition = create(:draft_policy)
    relationship = create(:edition_relation, document: edition.document)
    edition.destroy
    refute EditionRelation.exists?(relationship)
  end

  test "should be able to fetch case studies" do
    edition = create(:published_policy)
    case_study_1 = create(:published_case_study, related_editions: [edition])
    case_study_2 = create(:published_case_study, related_editions: [edition])
    case_study_3 = create(:draft_case_study, related_editions: [edition])
    random_publication = create(:published_publication, related_editions: [edition])
    assert_equal [case_study_1, case_study_2].to_set, edition.case_studies.to_set
  end

  test "should update count of published related publicationesques for publications" do
    policy = create(:published_policy)
    assert_equal 0, policy.published_related_publication_count

    publication = create(:published_publication)
    edition_relation = create(:edition_relation, document: policy.document, edition: publication)
    assert_equal 1, policy.reload.published_related_publication_count

    publication.update_attributes(state: :draft)
    assert_equal 0, policy.reload.published_related_publication_count

    publication.update_attributes(state: :published)
    assert_equal 1, policy.reload.published_related_publication_count

    edition_relation.reload.destroy
    assert_equal 0, policy.reload.published_related_publication_count
  end

  test "should update count of published related publicationesques for consultations" do
    policy = create(:published_policy)
    assert_equal 0, policy.published_related_publication_count

    consultation = create(:published_consultation)
    edition_relation = create(:edition_relation, document: policy.document, edition: consultation)
    assert_equal 1, policy.reload.published_related_publication_count

    consultation.update_attributes(state: :draft)
    assert_equal 0, policy.reload.published_related_publication_count

    consultation.update_attributes(state: :published)
    assert_equal 1, policy.reload.published_related_publication_count

    edition_relation.reload.destroy
    assert_equal 0, policy.reload.published_related_publication_count
  end

  test "search_index contains topics" do
    policy = create(:published_policy, :with_document, title: "my title", topics: [create(:topic)])

    assert_equal policy.topics.map(&:slug), policy.search_index['topics']
  end

  test 'search_format_types tags the policy as a policy' do
    policy = build(:policy)
    assert policy.search_format_types.include?('policy')
  end

  test 'can be associated with worldwide priorities' do
    assert Policy.new.can_be_associated_with_worldwide_priorities?
  end
end

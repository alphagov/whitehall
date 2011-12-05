require 'test_helper'

class PolicyAreaTest < ActiveSupport::TestCase
  test "should default to the 'current' state" do
    policy_area = PolicyArea.new
    assert policy_area.current?
  end

  test 'should be valid when built from the factory' do
    policy_area = build(:policy_area)
    assert policy_area.valid?
  end

  test 'should be invalid without a name' do
    policy_area = build(:policy_area, name: nil)
    refute policy_area.valid?
  end

  test "should be invalid without a state" do
    policy_area = build(:policy_area, state: nil)
    refute policy_area.valid?
  end

  test "should be invalid with an unsupported state" do
    policy_area = build(:policy_area, state: "foobar")
    refute policy_area.valid?
  end

  test 'should be invalid without a unique name' do
    existing_policy_area = create(:policy_area)
    new_policy_area = build(:policy_area, name: existing_policy_area.name)
    refute new_policy_area.valid?
  end

  test 'should be invalid without a description' do
    policy_area = build(:policy_area, description: nil)
    refute policy_area.valid?
  end

  test "should return a list of policy areas with published documents" do
    policy_area_with_published_policy = create(:policy_area, documents: [build(:published_policy)])
    policy_area_with_published_publication = create(:policy_area, documents: [build(:published_publication)])
    policy_area_with_published_policy_and_publication = create(:policy_area, documents: [build(:published_policy), build(:published_publication)])
    create(:policy_area, documents: [build(:draft_policy)])
    create(:policy_area, documents: [build(:draft_publication)])

    expected = [policy_area_with_published_policy, policy_area_with_published_publication, policy_area_with_published_policy_and_publication]
    assert_equal expected, PolicyArea.with_published_documents
  end

  test "should set a slug from the policy area name" do
    policy_area = create(:policy_area, name: 'Love all the people')
    assert_equal 'love-all-the-people', policy_area.slug
  end

  test "should not change the slug when the name is changed" do
    policy_area = create(:policy_area, name: 'Love all the people')
    policy_area.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', policy_area.slug
  end

  test "should concatenate words containing apostrophes" do
    policy_area = create(:policy_area, name: "Bob's bike")
    assert_equal 'bobs-bike', policy_area.slug
  end

  test "should allow setting ordering of associated documents" do
    policy_area = create(:policy_area)
    first_policy = create(:policy, policy_areas: [policy_area])
    second_policy = create(:policy, policy_areas: [policy_area])
    first_association = policy_area.document_policy_areas.find_by_document_id(first_policy.id)
    second_association = policy_area.document_policy_areas.find_by_document_id(second_policy.id)

    policy_area.update_attributes(document_policy_areas_attributes: {
      first_association.id => {id: first_association.id, document_id: first_policy.id, ordering: "2"},
      second_association.id => {id: second_association.id, document_id: second_policy.id, ordering: "1"}
    })

    assert_equal 2, first_association.reload.ordering
    assert_equal 1, second_association.reload.ordering
  end

  test "should not be destroyable when it has associated content" do
    policy_area_with_published_policy = create(:policy_area, documents: [build(:published_policy)])
    refute policy_area_with_published_policy.destroyable?
    assert_equal false, policy_area_with_published_policy.destroy
  end

  test ".featured includes all featured policy areas" do
    policy_area = create(:policy_area, featured: true)
    assert PolicyArea.featured.include?(policy_area)
  end

  test ".featured excludes unfeatured policy areas" do
    policy_area = create(:policy_area, featured: false)
    refute PolicyArea.featured.include?(policy_area)
  end

  test "return published documents relating to only *policies* in the policy area" do
    policy = create(:published_policy)
    news_article = create(:published_news_article)
    publication_1 = create(:published_publication, documents_related_to: [policy])
    publication_2 = create(:published_publication, documents_related_to: [news_article])
    policy_area = create(:policy_area, documents: [policy, news_article])

    assert_equal [publication_1], policy_area.published_related_documents
  end

  test "return published documents relating to policies in the policy area without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, documents_related_to: [policy_1])
    publication_2 = create(:published_publication, documents_related_to: [policy_1, policy_2])
    policy_area = create(:policy_area, documents: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], policy_area.published_related_documents
  end

  test "return only *published* documents relating to policies in the policy area" do
    published_policy = create(:published_policy)
    create(:draft_publication, documents_related_to: [published_policy])
    policy_area = create(:policy_area, documents: [published_policy])

    assert_equal [], policy_area.published_related_documents
  end

  test "return documents relating to only *published* policies in the policy area" do
    draft_policy = create(:draft_policy)
    create(:published_publication, documents_related_to: [draft_policy])
    policy_area = create(:policy_area, documents: [draft_policy])

    assert_equal [], policy_area.published_related_documents
  end

  test "return published documents relating from policies in the policy area without duplicates" do
    publication_1 = create(:published_publication)
    publication_2 = create(:published_publication)
    policy_1 = create(:published_policy, documents_related_to: [publication_1])
    policy_2 = create(:published_policy, documents_related_to: [publication_1, publication_2])
    policy_area = create(:policy_area, documents: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], policy_area.published_related_documents
  end

  test "return only *published* documents relating from policies in the policy area" do
    draft_publication = create(:draft_publication)
    published_policy = create(:published_policy, documents_related_to: [draft_publication])
    policy_area = create(:policy_area, documents: [published_policy])

    assert_equal [], policy_area.published_related_documents
  end

  test "return documents relating from only *published* policies in the policy area" do
    published_publication = create(:published_publication)
    draft_policy = create(:draft_policy, documents_related_to: [published_publication])
    policy_area = create(:policy_area, documents: [draft_policy])

    assert_equal [], policy_area.published_related_documents
  end

  test "should order by name by default" do
    policy_area_1 = create(:policy_area, name: "zzz")
    policy_area_2 = create(:policy_area, name: "aaa")
    assert_equal [policy_area_2, policy_area_1], PolicyArea.all
  end

  test "should exclude deleted policy areas by default" do
    current_policy_area = create(:policy_area)
    deleted_policy_area = create(:policy_area, state: "deleted")
    assert_equal [current_policy_area], PolicyArea.all
  end

  test "should transition to the deleted state" do
    policy_area = create(:policy_area)
    policy_area.delete!
    assert policy_area.deleted?
  end

end
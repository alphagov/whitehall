require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    article = build(:news_article)
    assert article.valid?
  end

  test "should be able to relate to other documents" do
    article = build(:news_article)
    assert article.can_be_related_to_other_documents?
  end

  test "#policy_areas includes policy areas associated with related published policies" do
    related_policy = create(:published_policy, policy_areas: [create(:policy_area), create(:policy_area)])
    news_article = create(:news_article, related_documents: [related_policy])
    assert_equal related_policy.policy_areas, news_article.policy_areas
  end

  test "#policy_areas excludes policy areas associated with related unpublished policies" do
    related_policy = create(:draft_policy, policy_areas: [create(:policy_area), create(:policy_area)])

    news_article = create(:news_article, related_documents: [related_policy])
    assert_equal [], news_article.policy_areas
  end

  test "#policy_areas includes each related policy area only once, even if associated multiple times" do
    policy_area = create(:policy_area)
    first_related_policy = create(:published_policy, policy_areas: [policy_area])
    second_related_policy = create(:published_policy, policy_areas: [policy_area])
    news_article = create(:news_article, related_documents: [first_related_policy, second_related_policy])
    assert_equal [policy_area], news_article.policy_areas
  end

  (Document.state_machine.states.map(&:name) - [:published]).each do |state|
    test "should be not featurable when #{state}" do
      refute build("#{state}_news_article").featurable?
    end
  end

  test "should be featurable when published" do
    assert build(:published_news_article).featurable?
  end
end
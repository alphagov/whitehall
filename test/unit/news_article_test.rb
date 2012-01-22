require "test_helper"

class NewsArticleTest < ActiveSupport::TestCase
  include DocumentBehaviour
  include ActionDispatch::TestProcess

  should_be_featurable :news_article

  test "should be valid when built from the factory" do
    article = build(:news_article)
    assert article.valid?
  end

  test "should be able to relate to other documents" do
    article = build(:news_article)
    assert article.can_be_related_to_policies?
  end

  test "#policy_areas includes policy areas associated with related published policies" do
    related_policy = create(:published_policy, policy_areas: [create(:policy_area), create(:policy_area)])
    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal related_policy.policy_areas, news_article.policy_areas
  end

  test "#policy_areas excludes policy areas associated with related unpublished policies" do
    related_policy = create(:draft_policy, policy_areas: [create(:policy_area), create(:policy_area)])

    news_article = create(:news_article, related_policies: [related_policy])
    assert_equal [], news_article.policy_areas
  end

  test "#policy_areas includes each related policy area only once, even if associated multiple times" do
    policy_area = create(:policy_area)
    first_related_policy = create(:published_policy, policy_areas: [policy_area])
    second_related_policy = create(:published_policy, policy_areas: [policy_area])
    news_article = create(:news_article, related_policies: [first_related_policy, second_related_policy])
    assert_equal [policy_area], news_article.policy_areas
  end

  test "should build a draft copy retaining any associated image with responds to present" do
    news_article = create(:published_news_article, image: fixture_file_upload('portas-review.jpg'))
    assert news_article.image.present?, "original image should be present for this test to be valid"

    draft_article = news_article.create_draft(create(:policy_writer))
    assert draft_article.image.present?
  end

  test "should build a draft copy retaining any associated feature image with responds to present" do
    featuring = create(:featuring, image: fixture_file_upload('portas-review.jpg'))
    news_article = create(:published_news_article, featuring: featuring)
    assert news_article.featuring.image.present?, "original feature image should be present for this test to be valid"

    draft_article = news_article.create_draft(create(:policy_writer))
    assert draft_article.featuring.image.present?
  end
end

require 'test_helper'
require 'support/importer_test_logger'

class Whitehall::Uploader::Finders::EditionFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
    @policy_finder = Whitehall::Uploader::Finders::EditionFinder.new(Policy, @log, @line_number)
  end

  test "returns the published edition of all policies found by the supplied slugs" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    assert_equal [policy_1, policy_2], @policy_finder.find(policy_1.slug, policy_2.slug)
  end

  test "returns the draft edition of any policies found by the supplied slugs which have no published editions" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:draft_policy, title: "Policy 2")
    assert_equal [policy_1, policy_2], @policy_finder.find(policy_1.slug, policy_2.slug)
  end

  test "returns the published edition even if a draft edition exists" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_1_draft = policy_1.create_draft(create(:user))
    assert_equal [policy_1], @policy_finder.find(policy_1.slug)
  end

  test "does not find other edition types which have the same slug" do
    news_article = create(:published_news_article, title: "Policy 1")
    assert_equal [], @policy_finder.find(news_article.slug)
    assert_match %r{Unable to find Policy with slug '#{news_article.slug}'}, @log_buffer.string
  end

  test "ignores blank slugs" do
    assert_equal [], @policy_finder.find('', '')
  end

  test "returns an empty array if a policy can't be found for the given slug" do
    assert_equal [], @policy_finder.find('made-up-policy-slug')
  end

  test "logs a warning if a policy can't be found for the given slug" do
    @policy_finder.find('made-up-policy-slug')
    assert_match /Unable to find Policy with slug 'made-up-policy-slug'/, @log_buffer.string
  end

  test "returns an empty array if the policy for the given slug that cannot be found" do
    assert_equal [], @policy_finder.find('made-up-policy-slug')
  end

  test "ignores duplicate related policies" do
    policy_1 = create(:published_policy, title: "Policy 1")
    assert_equal [policy_1], @policy_finder.find(policy_1.slug, policy_1.slug)
  end
end

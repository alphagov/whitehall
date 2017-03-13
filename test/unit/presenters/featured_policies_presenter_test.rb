require "test_helper"

class FeaturedPoliciesPresenterTest < ActionView::TestCase
  setup do
    @featured_policies = [
      build(:featured_policy, policy_content_id: SecureRandom.uuid),
      build(:featured_policy, policy_content_id: SecureRandom.uuid),
    ]
    @content_ids = @featured_policies.map(&:policy_content_id)
    @links = @content_ids.each_with_index.map do |content_id, i|
      count = i + 1
      {
        "content_id" => content_id,
        "title" => "Title #{count}",
        "base_path" => "/government/page-#{count}",
      }
    end
  end

  test "can use enumerable methods" do
    presenter = FeaturedPoliciesPresenter.new(@featured_policies, @links)
    assert_respond_to presenter, :map
    assert_respond_to presenter, :select
    assert_respond_to presenter, :to_a
  end

  test "populates Policy with details from links" do
    policy = FeaturedPoliciesPresenter.new(@featured_policies, @links).first
    expected = FeaturedPoliciesPresenter::Policy.new(
      @content_ids.first, "Title 1", "/government/page-1"
    )
    assert_equal policy, expected
  end

  test "fallsback to linkables when links aren't available" do
    content_id = SecureRandom.uuid
    featured_policies = [build(:featured_policy, policy_content_id: content_id)]

    policies = [
      {
        content_id: content_id,
        title: "Linkable",
        publication_state: "published",
        base_path: "/government/linkable",
        internal_name: "Internal Name",
      }
    ]
    publishing_api_has_linkables(policies, document_type: "policy")

    policy = FeaturedPoliciesPresenter.new(featured_policies, {}).first
    expected = FeaturedPoliciesPresenter::Policy.new(
      content_id, "Linkable", "/government/linkable"
    )
    assert_equal policy, expected
  end

  test "empty when there aren't featured policies" do
    presenter = FeaturedPoliciesPresenter.new([], @links)
    assert_empty presenter
  end

  test "empty when it can't match links" do
    featured_policies = [build(:featured_policy)]
    presenter = FeaturedPoliciesPresenter.new(featured_policies, @links)
    assert_empty presenter
  end
end

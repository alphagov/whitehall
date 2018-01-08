class FeaturedPoliciesPresenter
  include Enumerable

  delegate :empty?, to: :policies

  Policy = Struct.new(:content_id, :title, :base_path) do
    def link
      base_path
    end
  end

  def initialize(featured_policies, links)
    @featured_policies = featured_policies
    @links = links || {}
  end

  def each(&block)
    policies.each { |policy| yield(policy) }
  end

private

  attr_reader :featured_policies, :links

  def policies
    @policies ||= featured_policies.map { |fp| policy(fp) }.compact
  end

  def policy(featured_policy)
    policy = policy_from_links(featured_policy) || policy_from_linkables(featured_policy)
    Policy.new(*policy.values) if policy
  end

  def policy_from_links(featured_policy)
    link = links.find { |l| l["content_id"] == featured_policy.policy_content_id }
    link.symbolize_keys.slice(:content_id, :title, :base_path) if link
  end

  def policy_from_linkables(featured_policy)
    policy = linkables.find { |l| l.content_id == featured_policy.policy_content_id }
    policy.as_json.symbolize_keys.slice(:content_id, :title, :base_path) if policy
  end

  def linkables
    @linkables ||= ::Policy.all
  end
end

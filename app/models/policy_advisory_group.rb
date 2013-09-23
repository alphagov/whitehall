class PolicyAdvisoryGroup < PolicyGroup
  include ::Attachable

  validates_with SafeHtmlValidator

  def has_summary?
    true
  end

  def search_link
    Whitehall.url_maker.policy_advisory_group_path(slug)
  end
end

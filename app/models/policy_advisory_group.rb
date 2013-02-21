class PolicyAdvisoryGroup < PolicyGroup
  include ::Attachable

  attachable :policy_group

  validates_with SafeHtmlValidator

  def has_summary?
    true
  end

  def search_link
    policy_advisory_groups_path(slug)
  end
end

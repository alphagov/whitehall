class PolicyAdvisoryGroup < PolicyGroup
  include ::Attachable

  attachable :policy_group

  validates_with SafeHtmlValidator

  def has_summary?
    true
  end
end

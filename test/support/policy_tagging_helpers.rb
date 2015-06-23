require "gds_api/test_helpers/rummager"

module PolicyTaggingHelpers
  include GdsApi::TestHelpers::Rummager

  def assert_published_policies_returns_all_tagged_policies(object)
    rummager_has_policies_for_every_type

    all_policy_titles = [
      "Welfare reform",
      "State Pension simplification",
      "State Pension age",
      "Poverty and social justice",
      "Older people",
      "Household energy",
      "Health and safety reform",
      "European funds",
      "Employment",
      "Child maintenance reform",
    ]

    assert_equal all_policy_titles, object.published_policies.map(&:title)
  end
end

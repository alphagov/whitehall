require 'test_helper'

module DataHygiene
  class PolicyRedirectIdentifierTest < ActiveSupport::TestCase
    include ContentRegisterHelpers

    setup { stub_content_register_policies }

    test "returns the path for the corresponding future-policy" do
      policy = create(:published_policy)
      policy.document.update_column(:content_id, policy_1["content_id"])
      identifier = PolicyRedirectIdentifier.new(policy)

      assert_equal policy_1["base_path"], identifier.redirect_path
    end

    test "returns the path for the policy paper for retired policies" do
      retired_policy = create(:published_policy, id: 228679)
      replacement_publication = create(:published_publication, id: 489746)
      identifier = PolicyRedirectIdentifier.new(retired_policy)

      assert_equal Whitehall.url_maker.document_path(replacement_publication), identifier.redirect_path
    end
  end
end

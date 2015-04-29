require 'test_helper'

module DataHygiene
  class PolicyRedirectIdentifierTest < ActiveSupport::TestCase
    include ContentRegisterHelpers

    setup { stub_content_register_policies }

    test "returns the URL for the corresponding future-policy" do
      policy = create(:published_policy)
      policy.document.update_column(:content_id, policy_1["content_id"])
      identifier = PolicyRedirectIdentifier.new(policy)

      assert_equal "#{Whitehall.public_root}#{policy_1["base_path"]}", identifier.redirect_url
    end

    test "returns the URL for the policy paper for retired policies" do
      retired_policy = create(:published_policy, id: 228679)
      replacement_publication = create(:published_publication, id: 489746)
      identifier = PolicyRedirectIdentifier.new(retired_policy)

      assert_equal Whitehall.url_maker.document_url(replacement_publication), identifier.redirect_url
    end
  end
end

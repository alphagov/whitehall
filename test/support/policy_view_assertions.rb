module PolicyViewAssertions
  def assert_select_policy_section_link(policy, text, anchor)
    assert_select "ol#policy_sections" do
      assert_select "li a[href='#{policy_path(policy.document_identity, anchor: anchor)}']", text: text
    end
  end

  def refute_select_policy_section_link(policy, text, anchor)
    assert_select "ol#policy_sections" do
      assert_select "li a[href='#{policy_path(policy.document_identity, anchor: anchor)}']", text: text, count: 0
    end
  end
end
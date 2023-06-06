require "test_helper"

class PolicyGroupTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    policy_group = build(:policy_group, name: "")
    assert_not policy_group.valid?
  end

  test "should be valid without an email" do
    policy_group = build(:policy_group, email: "")
    assert policy_group.valid?
  end

  test "should be valid without a unique email" do
    existing_policy_group = create(:policy_group)
    new_policy_group = build(:policy_group, email: existing_policy_group.email)
    assert new_policy_group.valid?
  end

  test "should be invalid without a valid email" do
    policy_group = build(:policy_group, email: "invalid-email")
    assert_not policy_group.valid?
  end

  test "should allow a description" do
    policy_group = build(:policy_group, description: "policy-group-description")
    assert_equal "policy-group-description", policy_group.description
  end

  should_not_accept_footnotes_in(:description)

  test "publishes to the publishing API" do
    policy_group = create(:policy_group)
    Whitehall::PublishingApi.expects(:publish).with(policy_group).once
    policy_group.publish_to_publishing_api
  end

  test "#access_limited? returns false" do
    policy_group = FactoryBot.build(:policy_group)
    assert_not policy_group.access_limited?
  end

  test "#access_limited_object returns nil" do
    policy_group = FactoryBot.build(:policy_group)
    assert_nil policy_group.access_limited_object
  end

  test "is always publicly visible" do
    policy_group = FactoryBot.build(:policy_group)
    assert policy_group.publicly_visible?
  end

  test "is never unpublished" do
    policy_group = FactoryBot.build(:policy_group)
    assert_not policy_group.unpublished?
  end

  test "never has unpublished edition" do
    policy_group = FactoryBot.build(:policy_group)
    assert_nil policy_group.unpublished_edition
  end

  test "is always accessible" do
    policy_group = FactoryBot.build(:policy_group)
    assert policy_group.accessible_to?(nil)
  end

  test "populates dependencies when contacts are included in description" do
    contact_1 = FactoryBot.create(:contact)
    contact_2 = FactoryBot.create(:contact)
    policy_group = FactoryBot.create(
      :policy_group,
      description: "Some text with two contacts: [Contact:#{contact_1.id}] [Contact:#{contact_2.id}]",
    )

    assert_equal policy_group.depended_upon_contacts, [contact_1, contact_2]
  end

  test "updates dependencies when contacts are removed from the description" do
    contact_1 = FactoryBot.create(:contact)
    contact_2 = FactoryBot.create(:contact)
    policy_group = FactoryBot.create(
      :policy_group,
      description: "Some text with two contacts: [Contact:#{contact_1.id}] [Contact:#{contact_2.id}]",
    )

    policy_group.update!(description: "Some text with a single contact: [Contact:#{contact_2.id}]")

    assert_equal policy_group.depended_upon_contacts, [contact_2]
  end

  test "updates dependencies when contacts are added to the description" do
    contact_1 = FactoryBot.create(:contact)
    policy_group = FactoryBot.create(
      :policy_group,
      description: "Some text with a single contact: [Contact:#{contact_1.id}]",
    )

    contact_2 = FactoryBot.create(:contact)
    policy_group.update!(description: "Some text with two contacts: [Contact:#{contact_1.id}] [Contact:#{contact_2.id}]")

    assert_equal policy_group.depended_upon_contacts, [contact_1, contact_2]
  end

  test "deletes dependencies when policy group is deleted" do
    contact = FactoryBot.create(:contact)
    policy_group = FactoryBot.create(
      :policy_group,
      description: "Some text with a single contact: [Contact:#{contact.id}]",
    )

    policy_group.destroy!

    assert_empty policy_group.depended_upon_contacts
  end
end

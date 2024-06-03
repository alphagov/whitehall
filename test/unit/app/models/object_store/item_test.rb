require "test_helper"

class ObjectStore::ItemTest < ActiveSupport::TestCase
  setup do
    @item = build(:object_store_item, item_type: "email_address")
  end

  test "it creates accessors for an email address" do
    @item.email_address = "foo@example.com"

    assert_equal @item.email_address, "foo@example.com"
  end

  test "it validates the presence of an email address" do
    assert_not @item.valid?
    assert @item.errors[:email_address].any?
  end

  test "#summary_required? returns false" do
    assert_equal @item.summary_required?, false
  end

  test "#body_required? returns false" do
    assert_equal @item.body_required?, false
  end

  test "#previously_published returns false" do
    assert_equal @item.previously_published, false
  end

  test "item_type is required" do
    item = build(:object_store_item, item_type: nil)
    assert_not item.valid?
    assert item.errors[:item_type].any?
  end

  test "item_type cannot be changed" do
    @item.email_address = "foo@example.com"
    @item.save!

    @item.item_type = "foo"
    assert_not @item.valid?
    assert @item.errors[:item_type].include?("cannot be changed after creation")
  end

  test "item_type must be valid" do
    item = build(:object_store_item, item_type: "banana")

    assert_not item.valid?
    assert item.errors[:item_type].any?
  end
end

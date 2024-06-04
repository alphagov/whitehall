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
end

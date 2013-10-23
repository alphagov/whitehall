require 'test_helper'

class SluggingTest < ActiveSupport::TestCase

  test "should try and limit the length of the slug to 150" do
    document = create(:document, sluggable_string: "Availability of technologies for provisioning Home Area Network (HAN) connectivity to electricity and gas metering equipment, communications hub and in-home devices in cases where a 2.4GHz ZigBee wireless HAN will not work effectively")
    assert document.slug.length <= 150
  end

  test "should resolve a conflict" do
    document = create(:document, sluggable_string: "Slug conflict")
    document2 = create(:document, sluggable_string: "Slug conflict")
    assert_match /--2/, document2.slug
  end

  test "should strip punctuation properly" do
    document = create(:document, sluggable_string: "attorney general's")
    assert_equal "attorney-generals", document.slug
  end

  test "deleting should free up the slug" do
    d1 = create(:draft_policy, title: "test")
    force_publish(d1)
    d1.reload
    d1.unpublish!
    d1.delete!
    assert_equal "deleted-test", d1.reload.slug

    d2 = create(:draft_policy, title: "test")
    force_publish(d2)
    assert_equal "test", d2.slug
  end
end

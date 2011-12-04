require "test_helper"

class SupportingPageTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    supporting_page = build(:supporting_page)
    assert supporting_page.valid?
  end

  test "should be invalid without a title" do
    supporting_page = build(:supporting_page, title: nil)
    refute supporting_page.valid?
  end

  test "should be invalid without a body" do
    supporting_page = build(:supporting_page, body: nil)
    refute supporting_page.valid?
  end

  test "should be invalid without a document" do
    supporting_page = build(:supporting_page, document: nil)
    refute supporting_page.valid?
  end

  test "mark parent document as updated when supporting page is created" do
    parent_document = create(:draft_policy)
    lock_version = parent_document.lock_version

    supporting_page = create(:supporting_page, document: parent_document)

    refute_equal lock_version, parent_document.reload.lock_version
  end

  test "mark parent document as updated when supporting page is updated" do
    supporting_page = create(:supporting_page)
    parent_document = supporting_page.document
    lock_version = parent_document.lock_version

    supporting_page.update_attributes!(title: 'New title')

    refute_equal lock_version, parent_document.reload.lock_version
  end

  test "should set a slug from the supporting page title" do
    supporting_page = create(:supporting_page, title: 'Love all the people')
    assert_equal 'love-all-the-people', supporting_page.slug
  end

  test "should not change the slug when the title is changed" do
    supporting_page = create(:supporting_page, title: 'Love all the people')
    supporting_page.update_attributes(title: 'Hold hands')
    assert_equal 'love-all-the-people', supporting_page.slug
  end

  test "should concatenate words containing apostrophes" do
    supporting_page = create(:supporting_page, title: "Bob's bike")
    assert_equal 'bobs-bike', supporting_page.slug
  end

  test "should not be destroyable if its document is published" do
    supporting_page = create(:supporting_page, document: create(:published_policy))
    refute supporting_page.destroyable?
    refute supporting_page.destroy
    assert_nothing_raised { supporting_page.reload }
  end

  test "should be destroyable if its document is not published" do
    supporting_page = create(:supporting_page, document: create(:draft_policy))
    assert supporting_page.destroyable?
    assert supporting_page.destroy
    assert_raises(ActiveRecord::RecordNotFound) { supporting_page.reload }
  end
end
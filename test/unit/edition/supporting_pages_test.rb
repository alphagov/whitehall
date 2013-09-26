require "test_helper"

class Edition::SupportingPagesTest < ActiveSupport::TestCase
  test "#destroy should also remove the supporting pages" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)
    edition.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end

  test "#destroy should also remove the supporting pages for published editions" do
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    edition.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end

  test "supporting pages and their attachments are versioned when a new draft is created" do
    policy = create(:published_policy)
    attachment = create(:attachment)
    supporting_page = create(:supporting_page, edition: policy, attachments: [attachment])

    new_draft = policy.create_draft(create(:policy_writer))

    assert new_supporting_page = new_draft.supporting_pages.first
    assert_not_equal supporting_page, new_supporting_page
    assert_equal supporting_page.title, new_supporting_page.title
    assert_equal supporting_page.body, new_supporting_page.body

    assert new_attachment = new_supporting_page.attachments.first
    assert_not_equal attachment, new_attachment
    assert_equal attachment.title, new_attachment.title
    assert_equal attachment.attachment_data_id, new_attachment.attachment_data_id
  end
end

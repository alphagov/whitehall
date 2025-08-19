require "test_helper"

class AttachmentsTest < ActionDispatch::IntegrationTest
  setup do
    login_as_admin
  end

  test "displays attachment helper copy for non-publications" do
    edition = create(:edition)
    get "/government/admin/editions/#{edition.id}/attachments"
    assert_select ".govuk-inset-text", text: /need to be referenced/
  end

  test "displays different helper copy for publications" do
    publication = create(:publication)
    get "/government/admin/editions/#{publication.id}/attachments"
    assert_select ".govuk-inset-text", text: /publication will appear automatically/
  end

  test 'displays "will appear automatically" for consultations' do
    consultation = create(:consultation)
    get "/government/admin/editions/#{consultation.id}/attachments"
    assert_select ".govuk-inset-text", text: /consultation will appear automatically/
    refute_select ".govuk-inset-text", text: /need to be referenced/
  end
end

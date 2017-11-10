require 'test_helper'
require 'capybara/rails'

class AttachmentsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin
  end

  test 'displays attachment helper copy for non-publications' do
    edition = create(:edition)
    visit "/government/admin/editions/#{edition.id}/attachments"

    within ".qa-helper-copy" do
      assert_text "need to be referenced"
    end
  end

  test 'displays different helper copy for publications' do
    publication = create(:publication)
    visit "/government/admin/editions/#{publication.id}/attachments"

    within ".qa-helper-copy" do
      assert_text "publication will appear automatically"
    end
  end

  test 'displays "will appear automatically" for consultations' do
    consultation = create(:consultation)
    visit "/government/admin/editions/#{consultation.id}/attachments"

    within ".qa-helper-copy" do
      assert_text "consultation will appear automatically"
      assert_no_text "need to be referenced"
    end
  end
end

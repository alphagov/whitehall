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
      assert_text "will appear automatically"
    end
  end
end

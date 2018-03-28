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

  test "redirects asset requests that aren't made via the asset host when the filename contains multiple periods" do
    Plek.any_instance.stubs(:public_asset_host).returns('http://asset-host.com')
    host! 'not-asset-host.com'

    filename_with_multiple_periods = 'big-cheese.960x640.jpg'
    file = File.open(fixture_path.join(filename_with_multiple_periods))
    attachment_data = FactoryBot.create(:attachment_data, file: file)

    get "/government/uploads/system/uploads/attachment_data/file/#{attachment_data.id}/#{filename_with_multiple_periods}"

    assert_redirected_to "http://asset-host.com/government/uploads/system/uploads/attachment_data/file/#{attachment_data.id}/big-cheese.960x640.jpg"
  end
end

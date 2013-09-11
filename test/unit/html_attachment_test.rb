require 'test_helper'

class HtmlAttachmentTest < ActiveSupport::TestCase
  test '#url returns absolute path' do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    expected = "/government/publications/#{edition.slug}/#{attachment.slug}"
    assert_equal expected, attachment.url
  end
end

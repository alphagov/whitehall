require "test_helper"

class HtmlVersionTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :title, :body

  test 'belong to publications' do
    publication = build(:publication)
    HtmlVersion.new(edition_id: publication.id)
  end

  test 'is invalid without a title' do
    refute build(:html_version, title: nil).valid?
  end

  test 'is invalid without a body' do
    refute build(:html_version, body: nil).valid?
  end
end


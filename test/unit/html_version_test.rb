require "test_helper"

class HtmlVersionTest < ActiveSupport::TestCase
  test 'belong to publications' do
    publication = build(:publication)
    HtmlVersion.new(edition_id: publication.id)
  end
end


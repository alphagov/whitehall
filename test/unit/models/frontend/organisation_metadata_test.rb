require 'test_helper'

class Frontend::OrganisationMetadataTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::OrganisationMetadata.new(attrs)
  end

  test "it identifies by it's slug" do
    assert_equal "wombats-inc", build(slug: "wombats-inc").to_param
  end
end

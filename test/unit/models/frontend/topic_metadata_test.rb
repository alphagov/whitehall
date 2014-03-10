require 'test_helper'

class Frontend::TopicMetadataTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::TopicMetadata.new(attrs)
  end

  test "it identifies by it's slug" do
    assert_equal "animals", build(slug: "animals").to_param
  end
end

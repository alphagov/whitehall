require "test_helper"
require 'active_model_serializers'

class WithdrawnNoticeDetailsSerializerTest < ActiveSupport::TestCase
  def stubbed_item
    stub(
      withdrawn_at: 'a date',
      unpublishing: stub(explanation: explanation),
      updated_at: 'a date'
    )
  end

  def explanation
    "An explanation"
  end

  def serializer
    WithdrawnNoticeDetailsSerializer.new(stubbed_item)
  end

  test "it includes a withdrawn_at attribute" do
    assert_equal serializer.withdrawn_at, stubbed_item.withdrawn_at
  end

  test 'it includes an explanation attribute' do
    assert_equal(
      serializer.explanation,
      "<div class=\"govspeak\"><p>#{explanation}</p>\n</div>"
    )
  end
end

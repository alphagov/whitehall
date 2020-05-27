require "test_helper"

class ClassificationRoutesHelperTest < ActionView::TestCase
  %i[topical_event].each do |type|
    test "given a #{type} creates a #{type} path" do
      classification = create(type) # rubocop:disable Rails/SaveBang
      assert_equal send("#{type}_path", classification), classification_path(classification)
    end

    test "given a #{type} creates a #{type} url" do
      classification = create(type) # rubocop:disable Rails/SaveBang
      assert_equal send("#{type}_url", classification), classification_url(classification)
    end
  end
end

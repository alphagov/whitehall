module DocumentBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_image_attachments
      test "should include the Images behaviour module" do
        # *NOTE*. The Edition::Images module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class_from_test_name.ancestors.include?(Edition::Images)
      end
    end

    def should_not_allow_image_attachments
      test "should quack like something that includes the Images behaviour module" do
        assert edition_class_from_test_name.new.respond_to?(:images), "should respond to #images"
        assert edition_class_from_test_name.new.respond_to?(:lead_image), "should respond to #lead_image"
      end

      test "should return an empty array when asked for its images" do
        assert_equal [], edition_class_from_test_name.new.images
      end

      test "should return nil when asked for its lead_image" do
        assert_nil edition_class_from_test_name.new.lead_image
      end

      test "should indicate that it does not allow image attachments" do
        refute edition_class_from_test_name.new.allows_image_attachments?
      end
    end

    def should_be_attachable
      test "should include the Attachable behaviour module" do
        # *NOTE*. The Edition::Attachable module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class_from_test_name.ancestors.include?(Edition::Attachable)
      end
    end

    def should_allow_inline_attachments
      test "should allow inline attachments" do
        assert edition_class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_not_allow_inline_attachments
      test "should not allow inline attachments" do
        refute edition_class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_allow_a_summary_to_be_written
      test "should allow a summary to be written" do
        assert edition_class_from_test_name.new.has_summary?
      end
    end

    def should_not_allow_a_summary_to_be_written
      test "should not allow a summary to be written" do
        refute edition_class_from_test_name.new.has_summary?
      end
    end

  end
end

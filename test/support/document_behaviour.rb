module DocumentBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
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

  end
end

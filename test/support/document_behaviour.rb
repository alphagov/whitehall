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

    def should_allow_a_role_appointment
      test "should include the RoleAppointment module" do
        # *NOTE*. The Edition::Appointment module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class_from_test_name.ancestors.include?(Edition::Appointment)
      end
    end

    def should_allow_role_appointments
      test "should include the RoleAppointments module" do
        # *NOTE*. The Edition::RoleAppointments module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class_from_test_name.ancestors.include?(Edition::RoleAppointments)
      end
    end

    def should_be_attachable
      test "should include the Attachable behaviour module" do
        # *NOTE*. The ::Attachable module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class_from_test_name.ancestors.include?(::Attachable)
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
        assert edition_class_from_test_name.new.can_have_summary?
      end
    end

    def should_not_allow_a_summary_to_be_written
      test "should not allow a summary to be written" do
        refute edition_class_from_test_name.new.can_have_summary?
      end
    end

  end
end

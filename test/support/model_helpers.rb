module ModelHelpers
  extend ActiveSupport::Concern

  def assert_valid(model)
    assert model.valid?, "Expected #{model} to be valid."
  end

  def assert_invalid(model)
    assert_not model.valid?, "Expected #{model} not to be valid."
  end

  module ClassMethods
    def should_allow_image_attachments
      test "should include the Images behaviour module" do
        # *NOTE*. The Edition::Images module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::Images)
      end
    end

    def should_allow_referencing_of_statistical_data_sets
      test "should include the StatisticalDataSets module" do
        # *NOTE*. The Edition::StatisticalDataSet module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::StatisticalDataSets)
      end
    end

    def should_allow_a_role_appointment
      test "should include the RoleAppointment module" do
        # *NOTE*. The Edition::Appointment module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::Appointment)
      end
    end

    def should_allow_role_appointments
      test "should include the RoleAppointments module" do
        # *NOTE*. The Edition::RoleAppointments module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::RoleAppointments)
      end
    end

    def should_have_first_image_pulled_out
      test "should include the FirstImagePulledOut module" do
        # *NOTE*. The Edition::FirstImagePulledOut module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::FirstImagePulledOut)
      end
    end

    def should_be_attachable
      test "should include the Attachable behaviour module" do
        # *NOTE*. The ::Attachable module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(::Attachable)
      end
    end

    def should_allow_external_attachments
      test "should allow external attachments" do
        assert class_from_test_name.new.allows_external_attachments?
      end
    end

    def should_not_allow_external_attachments
      test "should not allow external attachments" do
        assert_not class_from_test_name.new.allows_external_attachments?
      end
    end

    def should_allow_inline_attachments
      test "should allow inline attachments" do
        assert class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_not_allow_inline_attachments
      test "should not allow inline attachments" do
        assert_not class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_allow_a_summary_to_be_written
      test "should allow a summary to be written" do
        assert class_from_test_name.new.can_have_summary?
      end
    end

    def should_not_allow_a_summary_to_be_written
      test "should not allow a summary to be written" do
        assert_not class_from_test_name.new.can_have_summary?
      end
    end

    def should_validate_with_safe_html_validator
      test "should validate with safe_html_validator" do
        instance = class_from_test_name.new
        SafeHtmlValidator.any_instance.expects(:validate).with(instance)
        instance.valid?
      end
    end

    def should_not_accept_footnotes_in(attribute_name)
      test "#{class_from_test_name.name} does not allow footnotes in #{attribute_name}" do
        instance = build(class_from_test_name.name.underscore)

        instance.public_send("#{attribute_name}=", 'text without footnote')
        assert instance.valid?

        instance.public_send("#{attribute_name}=", 'text with footnote[^1]')
        assert_not instance.valid?
      end
    end
  end
end

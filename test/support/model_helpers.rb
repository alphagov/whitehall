module ModelHelpers
  extend ActiveSupport::Concern

  def assert_valid(model)
    assert model.valid?, "Expected #{model} to be valid."
  end

  def assert_invalid(model)
    refute model.valid?, "Expected #{model} not to be valid."
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

    def should_allow_html_version
      test 'should include the HasHtmlVersion behaviour module' do
        # *NOTE*. The HasHtmlVersion module is tested separately so it
        # should be enough to just test its inclusion here.
        assert class_from_test_name.ancestors.include?(Edition::HasHtmlVersion)
      end
    end

    def should_allow_inline_attachments
      test "should allow inline attachments" do
        assert class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_not_allow_inline_attachments
      test "should not allow inline attachments" do
        refute class_from_test_name.new.allows_inline_attachments?
      end
    end

    def should_allow_a_summary_to_be_written
      test "should allow a summary to be written" do
        assert class_from_test_name.new.can_have_summary?
      end
    end

    def should_not_allow_a_summary_to_be_written
      test "should not allow a summary to be written" do
        refute class_from_test_name.new.can_have_summary?
      end
    end

    def should_validate_with_safe_html_validator
      test "should validate with safe_html_validator" do
        instance = class_from_test_name.new
        SafeHtmlValidator.any_instance.expects(:validate).with(instance)
        instance.valid?
      end
    end

    def should_support_linking_to_external_version
      test "external #{class_from_test_name.name.downcase.pluralize} must have a valid external URL" do
        edition = class_from_test_name.new(external: true, external_url: nil)

        refute edition.valid?
        assert_equal "can't be blank", edition.errors[:external_url].first

        edition.external_url = 'bad.url'
        refute edition.valid?
        assert_match /not valid/, edition.errors[:external_url].first
      end
    end
  end
end

module DocumentBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_be_featurable
      edition_class = edition_class_from_test_name
      edition_type = edition_class.name.underscore

      (Edition.state_machine.states.map(&:name) - [:published]).each do |state|
        test "should be not featurable when #{state}" do
          refute build("#{state}_#{edition_type}").featurable?
        end
      end

      test "should be featurable when published" do
        assert build("published_#{edition_type}").featurable?
      end

      test "should return the featured #{edition_type.to_s.pluralize}" do
        unfeatured = create(edition_type)
        featured = create("featured_#{edition_type}")
        assert_equal [featured], edition_class.featured
      end
    end

    def should_be_attachable
      edition_class = edition_class_from_test_name

      test "should include the Attachable behaviour module" do
        # *NOTE*. The Edition::Attachable module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class.ancestors.include?(Edition::Attachable)
      end
    end

  end
end
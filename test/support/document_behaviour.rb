module DocumentBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_be_featurable(document_type)
      document_class = edition_class_for(document_type)

      (Edition.state_machine.states.map(&:name) - [:published]).each do |state|
        test "should be not featurable when #{state}" do
          refute build("#{state}_#{document_type}").featurable?
        end
      end

      test "should be featurable when published" do
        assert build("published_#{document_type}").featurable?
      end

      test "should return the featured #{document_type.to_s.pluralize}" do
        unfeatured = create(document_type)
        featured = create("featured_#{document_type}")
        assert_equal [featured], document_class.featured
      end
    end

    def should_be_attachable(document_type)
      edition_class = edition_class_for(document_type)

      test "should include the Attachable behaviour module" do
        # *NOTE*. The Edition::Attachable module is tested separately so it
        # should be enough to just test its inclusion here.
        assert edition_class.ancestors.include?(Edition::Attachable)
      end
    end

  end
end
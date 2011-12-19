module DocumentBehaviour
  extend ActiveSupport::Concern

  module ClassMethods
    def should_be_featurable(document_type)
      document_class = document_class_for(document_type)

      (Document.state_machine.states.map(&:name) - [:published]).each do |state|
        test "should be not featurable when #{state}" do
          refute build("#{state}_#{document_type}").featurable?
        end
      end

      test "should be featurable when published" do
        assert build("published_#{document_type}").featurable?
      end

      test "should return the featured #{document_type.to_s.pluralize}" do
        unfeatured = create(document_type, featured: false)
        featured = create(document_type, featured: true)
        assert_equal [featured], document_class.featured
      end
    end
  end
end
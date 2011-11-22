module Document::AttributesForChildObjects
  extend ActiveSupport::Concern

  included do
    class_attribute :attributes_for_child_objects
    self.attributes_for_child_objects = []
  end

  module ClassMethods
    def attribute_for_child_objects(attribute)
      self.attributes_for_child_objects = self.attributes_for_child_objects.dup << attribute
    end
  end
end
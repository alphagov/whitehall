module Document::Traits
  extend ActiveSupport::Concern

  class Trait
    def initialize(document)
      @document = document
    end

    def assign_associations_to(document); end
    def copy_associations_to(document); end
  end

  included do
    class_attribute :traits
    self.traits = []

    define_method :traits do
      self.class.traits.map { |t| t.new(self) }
    end
  end

  module ClassMethods
    def add_trait(trait)
      self.traits = self.traits.dup << trait
    end
  end
end
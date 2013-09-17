module Edition::Traits
  extend ActiveSupport::Concern

  class Trait
    def initialize(edition)
      @edition = edition
    end

    def process_associations_before_save(edition); end

    def process_associations_after_save(edition); end
  end

  included do
    class_attribute :traits
    self.traits = []

    define_method :traits do
      self.class.traits.map { |t| t.new(self) }
    end
  end

  module ClassMethods
    def add_trait(trait = nil, &block)
      if trait.nil?
        if block_given?
          trait = Class.new(Edition::Traits::Trait, &block)
        else
          raise "you must provide a trait or a block"
        end
      end
      self.traits = self.traits.dup << trait
    end
  end
end

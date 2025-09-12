module ConfigurableAssociations
  class Organisations
    def initialize(association, errors)
      @association = association
      @errors = errors
    end

    attr_reader :errors
  end
end

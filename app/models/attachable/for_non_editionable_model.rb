module Attachable
  module ForNonEditionableModel
    extend ActiveSupport::Concern
    include ::Attachable

    def publicly_visible?
      true
    end

    def accessible_to?(_user)
      true
    end

    def access_limited?
      false
    end

    def access_limited_object
      nil
    end

    def organisations
      []
    end

    def unpublished?
      false
    end

    def unpublished_edition
      nil
    end
  end
end

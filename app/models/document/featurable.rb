module Document::Featurable
  extend ActiveSupport::Concern

  def featurable?
    published?
  end

  def feature(featuring_image = nil)
    attributes = {featured: true}
    attributes.merge!(featuring_image: featuring_image) if featuring_image
    update_attributes(attributes)
  end

  def unfeature
    update_attributes(featured: false)
  end

  module ClassMethods
    def featured
      where featured: true
    end

    def not_featured
      where featured: false
    end
  end
end
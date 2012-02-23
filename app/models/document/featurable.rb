module Document::Featurable
  extend ActiveSupport::Concern

  def featurable?
    published?
  end

  def feature
    update_attributes(featured: true)
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
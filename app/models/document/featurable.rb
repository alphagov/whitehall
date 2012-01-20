module Document::Featurable
  extend ActiveSupport::Concern

  def featurable?
    published?
  end

  def feature
    update_attribute(:featured, true)
  end

  def unfeature
    update_attribute(:featured, false)
  end

  module ClassMethods
    def featured
      where featured: true
    end
  end
end
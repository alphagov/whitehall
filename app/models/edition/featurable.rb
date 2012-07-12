module Edition::Featurable
  extend ActiveSupport::Concern

  included do
    scope :featured, where(featured: true)
    scope :not_featured, where(featured: false)
  end

  def featurable?
    published?
  end

  def feature
    update_attributes(featured: true)
  end

  def unfeature
    update_attributes(featured: false)
  end
end

module Document::Featurable
  extend ActiveSupport::Concern

  def featurable?
    published?
  end

  module ClassMethods
    def featured
      where featured: true
    end
  end
end
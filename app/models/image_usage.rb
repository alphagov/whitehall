class ImageUsage
  include ActiveModel::API

  attr_accessor :key, :label, :kinds, :multiple, :embeddable

  alias_method :embeddable?, :embeddable
  alias_method :multiple?, :multiple
end

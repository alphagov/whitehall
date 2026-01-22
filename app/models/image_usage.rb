class ImageUsage
  include ActiveModel::API

  attr_accessor :key, :label, :kinds, :multiple

  alias_method :multiple?, :multiple

  def embeddable?
    key == "govspeak_embed"
  end
end

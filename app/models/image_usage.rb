class ImageUsage
  include ActiveModel::API

  attr_accessor :key, :label, :kinds, :multiple, :caption_enabled

  alias_method :multiple?, :multiple

  def initialize(attributes = {})
    super
    self.caption_enabled = true if caption_enabled.nil?
  end

  def caption_enabled?
    caption_enabled
  end

  def embeddable?
    key == "govspeak_embed"
  end

  def lead?
    key == "lead"
  end

  def title
    return "image" if embeddable?

    label || "#{key} image"
  end
end

class FeaturedImageUploader < ImageUploader
  def extension_allowlist
    %w[jpg jpeg gif png].freeze
  end
end

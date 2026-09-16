class WhitehallUploader < CarrierWave::Uploader::Base
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def bitmap?(new_file)
    return if new_file.nil?

    new_file.content_type !~ /svg/
  end

  # Returns path to the file, relative to the [incoming|clean] root.
  def relative_path
    store_path(File.basename(path))
  end

  def assets_protected?
    false
  end

  def asset_params
    {
      assetable_id: model.id,
      asset_variant: version_name ? Asset.variants[version_name] : Asset.variants[:original],
      assetable_type: model.class.to_s,
    }.deep_stringify_keys
  end

  def active_version_names
    # active_versions is protected, so it can only be called by subclasses
    # it returns an array of [key, value] pairs, and we want the keys
    active_versions.map(&:first)
  end
end

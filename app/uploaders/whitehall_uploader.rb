class WhitehallUploader < CarrierWave::Uploader::Base
  before :cache, :validate_filename_length

  def validate_filename_length(file)
    unless valid_filename_length(full_filename(file.file))
      raise CarrierWave::IntegrityError, "has too long of a filename"
    end
  end

  def valid_filename_length(filename)
    # Windows apparently supports filenames up to 260 characters!
    # this is longer than all other operating systems (255 characters)
    # so a user can upload a file which is invalid on the server OS :(
    filename.length <= 255
  end

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
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
end

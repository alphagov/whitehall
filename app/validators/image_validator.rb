class ImageValidator < ActiveModel::Validator
  DEFAULT_MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif" => /\.gif$/,
    "image/png" => /\.png$/,
    "image/svg+xml" => /\.svg$/,
  }.freeze

  def initialize(options = {})
    super
    @method     = options[:method] || :file
    @mime_types = options[:mime_types] || DEFAULT_MIME_TYPES
  end

  def validate(record)
    return if file_for(record).blank?
    return unless File.exist?(file_for(record).path)

    begin
      image_path = file_for(record).path
      validate_mime_type(record, image_path)
      image = MiniMagick::Image.open(image_path)

      unless Marcel::MimeType.for(Pathname.new(image_path)).match?(/svg/)
        validate_size(record, image)
      end
    rescue MiniMagick::Error, MiniMagick::Invalid
      record.errors.add(@method, "could not be read. The file may not be an image or may be corrupt")
    end
  end

private

  def validate_mime_type(record, file_path)
    mime_type = Marcel::MimeType.for(Pathname.new(file_path))
    if @mime_types[mime_type].nil?
      record.errors.add(@method, "is not of an allowed type")
    elsif !file_path.downcase.match?(@mime_types[mime_type])
      record.errors.add(@method, "is of type '#{mime_type}', but has the extension '.#{file_path.rpartition('.').last}'.")
    end
  end

  def validate_size(record, image)
    return unless record.respond_to?(:image_kind_config)

    actual_width = image[:width]
    actual_height = image[:height]
    target_width = record.image_kind_config.valid_width
    target_height = record.image_kind_config.valid_height

    too_small = actual_width < target_width || actual_height < target_height

    return unless too_small

    record.errors.add(@method, :too_small, message: "is too small. Select an image that is at least #{target_width} pixels wide and at least #{target_height} pixels tall")
  end

  def file_for(record)
    record.public_send(@method)
  end
end

class ImageValidator < ActiveModel::Validator
  DEFAULT_MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif" => /\.gif$/,
    "image/png" => /\.png$/,
  }.freeze

  def initialize(options = {})
    super
    @method     = options[:method] || :file
    @size       = options[:size] || nil
    @mime_types = options[:mime_types] || DEFAULT_MIME_TYPES
  end

  def validate(record)
    return if file_for(record).blank?
    return unless File.exist?(file_for(record).path)
    return if file_for(record).file.content_type.match?(/svg/) && file_for(record).model.class != TopicalEvent

    begin
      image = MiniMagick::Image.open file_for(record).path
      validate_mime_type(record, image)
      validate_size(record, image)
    rescue MiniMagick::Error, MiniMagick::Invalid
      record.errors.add(@method, "could not be read. The file may not be an image or may be corrupt")
    end
  end

private

  def validate_mime_type(record, image)
    if @mime_types[image.mime_type].nil?
      record.errors.add(@method, "is not of an allowed type")
    elsif !file_for(record).path.downcase.match?(@mime_types[image.mime_type])
      record.errors.add(@method, "is of type '#{image.mime_type}', but has the extension '.#{file_for(record).path.split('.').last}'.")
    end
  end

  def validate_size(record, image)
    return unless @size

    actual_width = image[:width]
    actual_height = image[:height]
    target_width = @size[0]
    target_height = @size[1]

    too_small = actual_width < target_width || actual_height < target_height
    too_large = actual_width > target_width || actual_height > target_height

    return unless too_small || too_large

    error_type = too_small ? :too_small : :too_large
    problem = too_small ? "too small" : "too large"
    message = "is #{problem}. Select an image that is #{target_width} pixels wide and #{target_height} pixels tall"
    record.errors.add(@method, error_type, message:)
  end

  def file_for(record)
    record.public_send(@method)
  end
end

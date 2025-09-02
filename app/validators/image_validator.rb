class ImageValidator < ActiveModel::Validator
  DEFAULT_MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif" => /\.gif$/,
    "image/png" => /\.png$/,
  }.freeze

  def initialize(options = {})
    super
    @method     = options[:method] || :file
    @mime_types = options[:mime_types] || DEFAULT_MIME_TYPES
  end

  def validate(record)
    return if file_for(record).blank?
    return unless File.exist?(file_for(record).path)
    return if file_for(record).file.content_type.match?(/svg/)

    begin
      image_path = file_for(record).path
      validate_mime_type(record, image_path)
      MiniMagick::Image.open(image_path)
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

  def file_for(record)
    record.public_send(@method)
  end
end

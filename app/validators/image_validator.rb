class ImageValidator < ActiveModel::Validator
  DEFAULT_MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif"  => /\.gif$/,
    "image/png"  => /\.png$/
  }

  def initialize(options = {})
    super
    @method     = options[:method] || :file
    @size       = options[:size] || nil
    @mime_types = options[:mime_types] || DEFAULT_MIME_TYPES
  end

  def validate(record)
    return unless file_for(record).present?

    begin
      image = MiniMagick::Image.open file_for(record).path
      validate_mime_type(record, image)
      validate_size(record, image)

    rescue MiniMagick::Error => e
      record.errors.add(@method, "could not be read. The file may not be an image or may be corrupt")
    end
  end

  private

  def validate_mime_type(record, image)
    if @mime_types[image.mime_type].nil?
      record.errors.add(@method, "is not of an allowed type")
    end
    unless file_for(record).path.downcase =~ @mime_types[image.mime_type]
      record.errors.add(@method, "is of type '#{image.mime_type}', but has the extension '.#{file_for(record).path.split('.').last}'.")
    end
  end

  def validate_size(record, image)
    return unless @size

    unless (image[:width] == @size[0] && image[:height] == @size[1])
      record.errors.add(@method, "must be #{@size[0]}px wide and #{@size[1]}px tall, but is #{image[:width]}px wide and #{image[:height]}px tall")
    end
  end

  def file_for(record)
    record.public_send(@method)
  end
end

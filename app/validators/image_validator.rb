class ImageValidator < ActiveModel::Validator
  DEFAULT_MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif"  => /\.gif$/,
    "image/png"  => /\.png$/
  }

  def initialize(options = {})
    super
    @method       = options[:method] || :file
    @size         = options[:size] || nil
    @minimum_size = options[:minimum_size] || nil
    @maximum_size = options[:maximum_size] || nil
    @mime_types   = options[:mime_types] || DEFAULT_MIME_TYPES
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
    if @size && !image_exact_size?(image)
      record.errors.add(@method, exact_size_error(image) )
    end

    if @minimum_size && !image_minimum_size?(image)
      record.errors.add(@method, minimum_size_error(image) )
    end

    if @maximum_size && !image_maximum_size?(image)
      record.errors.add(@method, maximum_size_error(image) )
    end
  end

  def file_for(record)
    record.public_send(@method)
  end

  def image_exact_size?(image)
    image[:width] == @size[0] && image[:height] == @size[1]
  end

  def image_minimum_size?(image)
    image[:width] >= @minimum_size[0] && image[:height] >= @minimum_size[1]
  end

  def image_maximum_size?(image)
    image[:width] <= @maximum_size[0] && image[:height] <= @maximum_size[1]
  end

  def exact_size_error(image)
    "must be #{@size[0]}px wide and #{@size[1]}px tall, but is #{image[:width]}px wide and #{image[:height]}px tall"
  end

  def minimum_size_error(image)
    "must be at least #{@minimum_size[0]}px wide and #{@minimum_size[1]}px tall, but is #{image[:width]}px wide and #{image[:height]}px tall"
  end

  def maximum_size_error(image)
    "must be at most #{@maximum_size[0]}px wide and #{@maximum_size[1]}px tall, but is #{image[:width]}px wide and #{image[:height]}px tall"
  end
end

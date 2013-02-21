class ImageSizeChecker
  def initialize(file_path)
    raise ArgumentError, 'need a file path' unless file_path.present?
    @file_path = file_path
  end

  def size_is?(width, height)
    image = MiniMagick::Image.open(@file_path)
    (image[:width] == width && image[:height] == height)
  end
end

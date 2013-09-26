module Whitehall::Uploader
  class FatalityNoticeRow < Row
    def initialize(row, line_number, _, logger = Logger.new($stdout), image_cache = nil)
      @row = row
      @line_number = line_number
      @logger = logger
      @image_cache = image_cache || FatalityNoticeImageCache.new(FatalityNoticeImageCache.default_root_directory, logger, line_number)
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body})
        .multiple(%w{image_#_imgalt image_#_imgcap image_#_imgcapmd image_#_imgurl}, 0..4)
        .ignored("ignore_*")
        .required(%w{first_published field_of_operation roll_call_introduction})
    end

    def images
      1.upto(4).map do |image_number|
        field_names = "image_#{image_number}_imgalt image_#{image_number}_imgcap image_#{image_number}_imgcapmd image_#{image_number}_imgurl".split(" ")
        image_attributes = Hash[field_names.map do |field_name|
          suffix = field_name.sub(/^image_#{image_number}_/, "")
          [suffix, row[field_name]]
        end]
        next if image_attributes.values.all?(&:blank?)
        ImageBuilder.new(@image_cache, @logger, @line_number).build(image_attributes)
      end.compact
    end

    def operational_field
      Finders::OperationalFieldFinder.find(row['field_of_operation'], @logger, @line_number)
    end

    def first_published_at
      Parsers::DateParser.parse(row['first_published'], @logger, @line_number)
    end

    def roll_call_introduction
      row['roll_call_introduction']
    end

    def organisation
      Organisation.find_by_slug("ministry-of-defence")
    end

    def attributes
      [:title, :summary, :body, :lead_organisations, :images, :operational_field, :first_published_at, :roll_call_introduction].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

    private

    class ImageBuilder
      def initialize(image_cache, logger, line_number)
        @image_cache = image_cache
        @logger = logger
        @line_number = line_number
      end

      def build(image_attributes)
        filehandle = @image_cache.fetch(image_attributes['imgurl'])
        Image.new(image_data: ImageData.new(file: filehandle),
          alt_text: image_attributes["imgalt"],
          caption: image_attributes["imgcapmd"])
      end
    end
  end
end

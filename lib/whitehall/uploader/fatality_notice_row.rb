require 'whitehall/uploader/row'
require 'whitehall/uploader/finders/operational_field_finder'
require 'whitehall/uploader/finders/operational_field_finder'

module Whitehall::Uploader
  class FatalityNoticeRow < Row
    attr_reader :row

    def initialize(row, line_number, _, logger = Logger.new($stdout), image_cache = nil)
      @row = row
      @line_number = line_number
      @logger = logger
      @image_cache = image_cache || FatalityNoticeImageCache.new(FatalityNoticeImageCache.default_root_directory, logger)
    end

    def self.validator
      HeadingValidator.new
        .required(%w{old_url title summary body})
        .multiple(%w{image_#_imgalt image_#_imgcap image_#_imgcapmd image_#_imgurl}, 0..4)
        .ignored("ignore_*")
        .required(%w{first_published field_of_operation})
    end

    def title
      row['title']
    end

    def summary
      row['summary']
    end

    def body
      row['body']
    end

    def legacy_url
      row['old_url']
    end

    def organisations
      [Organisation.find_by_slug("ministry-of-defence")]
    end

    def lead_edition_organisations
      organisations.map.with_index do |o, idx|
        Builders::EditionOrganisationBuilder.build_lead(o, idx+1)
      end
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

    def attributes
      [:title, :summary, :body, :lead_edition_organisations, :images, :operational_field, :first_published_at].map.with_object({}) do |name, result|
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

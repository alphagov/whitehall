module SpecialistTopicMigration
  class SpecialistTopic
    attr_reader :base_path

    def self.find!(base_path)
      content_id = Services.publishing_api.lookup_content_id(base_path:)
      content_hash = Services.publishing_api.get_content(content_id).parsed_content

      new(content_hash)
    end

    def initialize(content_hash)
      @content_hash = content_hash
    end

    %i[base_path title description content_id details].each do |field|
      define_method field do
        @content_hash[field.to_s]
      end
    end
  end
end

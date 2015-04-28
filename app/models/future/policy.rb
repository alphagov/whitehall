# A model to represent new-world policies that are published by policy-publisher
# and stored in the content-store.
module Future
  class Policy
    attr_reader :base_path, :content_id, :title

    def initialize(attributes)
      @base_path = attributes["base_path"]
      @content_id = attributes["content_id"]
      @title = attributes["title"]
    end

    def self.all
      Whitehall.content_register.entries('policy').map {|attrs| new(attrs.to_hash) }
    end

    def self.from_content_ids(content_ids)
      content_ids.map do |content_id|
        if match = Whitehall.content_register.entries("policy").find { |p| p["content_id"] == content_id }
          new(match)
        end
      end.compact
    end

    def topics
      []
    end

    def slug
      @slug ||= base_path.split('/').last
    end
  end
end

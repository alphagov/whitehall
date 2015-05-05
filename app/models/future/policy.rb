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

    def self.find(content_id)
      if attributes = find_entry(content_id)
        new(attributes)
      end
    end

    def self.all
      entries.map { |attrs| new(attrs) }
    end

    def self.from_content_ids(content_ids)
      content_ids.map { |content_id| find(content_id) }.compact
    end

    def topics
      []
    end

    def slug
      @slug ||= base_path.split('/').last
    end

  private

    def self.entries
      content_register.entries("policy")
    end

    def self.find_entry(content_id)
      entries.find { |p| p["content_id"] == content_id }
    end

    def self.content_register
      @content_register ||= Whitehall.content_register
    end
  end
end

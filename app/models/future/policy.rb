# A model to represent new-world policies that are published by policy-publisher
# and stored in the content-store.
module Future
  class Policy
    include ActiveModel::Model

    attr_reader :base_path, :content_id, :slug, :title, :summary

    def initialize(attributes)
      attributes = attributes.with_indifferent_access

      @base_path = attributes["base_path"]
      @content_id = attributes["content_id"]
      @title = attributes["title"]
      @summary = attributes["summary"]
      @slug = extract_slug
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

    def self.from_rummager(rummager_results)
      rummager_results.map do |rummager_policy|
        rummager_policy = rummager_policy.marshal_dump

        new(
          base_path: rummager_policy[:link],
          title: rummager_policy[:title],
          summary: rummager_policy[:description]
        )
      end
    end

    def topics
      []
    end

  private
    def extract_slug
      base_path.split('/').last
    end
  end
end

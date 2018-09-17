require 'uri'

class UrlToSubscriberListCriteria
  EMAIL_SUPERTYPE = "email_document_supertype".freeze
  GOVERNMENT_SUPERTYPE = "government_document_supertype".freeze
  class UnprocessableUrl < StandardError; end

  def initialize(url, static_data = StaticData)
    @url = URI.parse(url.strip)
    @static_data = static_data
  end

  def convert
    @convert ||= begin
      hash = map_url_to_hash.dup
      if hash["links"]
        links = hash["links"].each_with_object({}) do |(key, values), result|
          result[key] = values.map { |value| lookup_content_id(key, value) }
        end
        hash["links"] = links
      end
      hash
    end
  end

  def map_url_to_hash
    @map_url_to_hash ||= begin
      result = if @url.path.match?(%r{^/government/statistics\.atom$})
                 { "links" => from_params, EMAIL_SUPERTYPE => "publications", GOVERNMENT_SUPERTYPE => "statistics" }
               elsif @url.path.match?(%r{^/government/publications\.atom$})
                 { "links" => from_params, EMAIL_SUPERTYPE => "publications" }
               elsif @url.path.match?(%r{^/government/announcements\.atom$})
                 { "links" => from_params, EMAIL_SUPERTYPE => "announcements" }
               elsif (path_match = @url.path.match(%r{^/government/people/(.*)\.atom$}))
                 { "links" => from_params.merge("people" => [path_match[1]]) }
               elsif (path_match = @url.path.match(%r{^/government/ministers/(.*)\.atom$}))
                 { "links" => from_params.merge("roles" => [path_match[1]]) }
               elsif (path_match = @url.path.match(%r{^/government/organisations/(.*)\.atom$}))
                 { "links" => from_params.merge("organisations" => [path_match[1]]) }
               elsif (path_match = @url.path.match(%r{^/government/topical-events/(.*)\.atom$}))
                 { "links" => from_params.merge("topical_events" => [path_match[1]]) }
               elsif (path_match = @url.path.match(%r{^/government/topics/(.*)\.atom$}))
                 { "links" => from_params.merge(topic_map([path_match[1]]) => [path_match[1]]) }
               elsif (path_match = @url.path.match(%r{^/world/(.*)\.atom$}))
                 { "links" => from_params.merge("world_locations" => [path_match[1]]) }
               elsif @url.path.match?(%r{/government/feed})
                 { 'links' => from_params }
               else
                 raise UnprocessableUrl, @url.to_s
               end

      if result.fetch("links", {})["publication_filter_option"]
        result[GOVERNMENT_SUPERTYPE] = result["links"].delete("publication_filter_option")
      end
      if result.fetch("links", {})["announcement_filter_option"]
        result[GOVERNMENT_SUPERTYPE] = result["links"].delete("announcement_filter_option")
      end

      result
    end
  end

  def from_params
    Rack::Utils.parse_nested_query(@url.query).tap do |result|
      if result.key?('departments')
        result['organisations'] = result.delete('departments')
      end
      if result.key?('topics')
        values = result.delete('topics')
        result[topic_map(values)] = values
      end
    end
  end

  def topic_map(values)
    @static_data.topical_event?(values) ? 'topical_events' : 'policy_areas'
  end

  def lookup_content_id(key, slug)
    @static_data.content_id(key, slug)
  end

  module StaticData
    class UnknownStaticDataKey < StandardError; end

    def self.topical_event?(values)
      TopicalEvent.where(slug: values).any?
    end

    def self.content_id(key, slug)
      lookup_map = {
        "world_locations" => WorldLocation,
        "organisations" => Organisation,
        "roles" => Role,
        "people" => Person,
        "topical_events" => Classification,
        "policy_areas" => Classification,
      }

      lookup_class = lookup_map[key] || raise(UnknownStaticDataKey, key)
      lookup_class.find_by!(slug: slug).content_id
    end
  end
end

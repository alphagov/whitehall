require 'uri'

class UrlToSubscriberListCriteria
  MISSING_LOOKUP = "*** MISSING KEY ***".freeze
  EMAIL_SUPERTYPE = "email_document_supertype".freeze
  GOVERNMENT_SUPERTYPE = "government_document_supertype".freeze
  class UnprocessableUrl < StandardError; end

  def initialize(url, static_data = StaticData)
    @url = URI.parse(url.strip)
    @static_data = static_data
    @missing_lookups = []
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

  def missing_lookup
    convert
    @missing_lookups.to_sentence if @missing_lookups.any?
  end

  def map_url_to_hash
    @map_url_to_hash ||= begin
      result = if @url.path =~ %r{^/government/statistics\.atom$}
                 { "links" => from_params, EMAIL_SUPERTYPE => "publications", GOVERNMENT_SUPERTYPE => "statistics" }
               elsif @url.path =~ %r{^/government/publications\.atom$}
                 { "links" => from_params, EMAIL_SUPERTYPE => "publications" }
               elsif @url.path =~ %r{^/government/announcements\.atom$}
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
               elsif @url.path =~ %r{/government/feed}
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
    return {} if @url.query.blank?

    result = Rack::Utils.parse_nested_query(@url.query)
    {
      'departments' => 'organisations',
      'topics' => method(:topic_map),
    }.each do |from_key, to_key|
      next unless result.key?(from_key)

      if to_key.is_a?(String)
        result[to_key] = result.delete(from_key)
      else
        values = result.delete(from_key)
        result[to_key.call(values)] = values
      end
    end
    result
  end

  def topic_map(values)
    @static_data.topical_event?(values) ? 'topical_events' : 'policy_areas'
  end

  def lookup_content_id(key, slug)
    @static_data.content_id(key, slug).tap do |value|
      @missing_lookups << "#{key}: #{slug}" if value == MISSING_LOOKUP
    end
  end

  # Static data can currently be injected into the mapping process in two forms.
  # This was done to allow optimisation of the process depending on the use case.
  # - BulkStaticData which is designed to be used with the mass migration of data
  #   and can be deleted once the migration is complete.
  # - StaticData which uses standard DB queries and is expected to be used when
  #   converting individual URLs.
  class BulkStaticData
    def topical_event?(values)
      @topical_events ||= TopicalEvent.pluck(:slug)
      (@topical_events & values).any?
    end

    def content_id(key, slug)
      case key
      when "world_locations"
        @world_locations_lookup ||= Hash[WorldLocation.pluck(:slug, :content_id)]
        @world_locations_lookup.fetch(slug, UrlToSubscriberListCriteria::MISSING_LOOKUP)
      when "organisations"
        @organisations_lookup ||= Hash[Organisation.pluck(:slug, :content_id)]
        @organisations_lookup.fetch(slug, UrlToSubscriberListCriteria::MISSING_LOOKUP)
      when "roles"
        @roles_lookup ||= Hash[Role.pluck(:slug, :content_id)]
        @roles_lookup.fetch(slug, UrlToSubscriberListCriteria::MISSING_LOOKUP)
      when "people"
        @people_lookup ||= Hash[Person.pluck(:slug, :content_id)]
        @people_lookup.fetch(slug, UrlToSubscriberListCriteria::MISSING_LOOKUP)
      when "policy_areas", "topical_events"
        @classifications_lookup ||= Hash[Classification.pluck(:slug, :content_id)]
        @classifications_lookup.fetch(slug, UrlToSubscriberListCriteria::MISSING_LOOKUP)
      else
        raise [key, slug].inspect
      end
    end
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

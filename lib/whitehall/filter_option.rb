module Whitehall
  class FilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :search_format_types, :group_key
    attr_writer :edition_types, :slug

    def slug
      @slug || label.downcase.gsub(/[^a-z]+/, "-")
    end

    def edition_types
      @edition_types || []
    end

    def self.find_by_slug(slug)
      all.detect { |pt| pt.slug == slug }
    end

    def self.find_by_search_format_types(format_types)
      all.detect do |at|
        format_types.any? {|t| at.search_format_types.include?(t)}
      end
    end
  end
end

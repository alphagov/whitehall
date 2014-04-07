module Searchable
  extend ActiveSupport::Concern

  SEARCH_FIELDS = [
    :id, :title, :acronym, :link, :content,
    :section, :subsection, :subsubsection,
    :format, :boost_phrases, :description,
    :organisations, :public_timestamp,
    :people, :publication_type, :speech_type,
    :topics, :news_article_type, :display_type,
    :slug, :search_format_types, :world_locations,
    :attachments, :operational_field, :organisation_state,
    :release_timestamp, :metadata
  ]

  included do
    class_attribute :searchable_options
  end

  module ClassMethods
    def searchable(options)
      include Searchable::Mixin

      self.searchable_options = options.reverse_merge \
        format:         -> o { o.class.model_name.element },
        index_after:    :save,
        unindex_after:  :destroy,
        only:           :scoped,
        description:    ""

      self.searchable_options[:index_after] = [self.searchable_options[:index_after]].flatten.select { |e| e }
      self.searchable_options[:unindex_after] = [self.searchable_options[:unindex_after]].flatten.select { |e| e }

      (SEARCH_FIELDS + [:only]).each do |name|
        value = searchable_options[name]
        searchable_options[name] =
          if value.respond_to?(:call)
            # use procs verbatim
            value
          elsif value.respond_to?(:to_proc)
            # turn willing objects (e.g. symbols) into procs
            value.to_proc
          else
            # treat other objects (e.g. strings) as constants
            -> _ { value }
          end
      end

      searchable_options[:index_after].each do |event|
        set_callback event, :after, :update_in_search_index
      end
      searchable_options[:unindex_after].each do |event|
        set_callback event, :after, :remove_from_search_index
      end
    end
  end

  module Mixin
    extend ActiveSupport::Concern

    KEY_MAPPING = {
      content: 'indexable_content'
    }

    def search_index
      SEARCH_FIELDS.reduce({}) do |result, name|
        value = searchable_options[name].call(self)
        key = KEY_MAPPING[name] || name.to_s
        result[key] = value unless value.nil?
        result
      end
    end

    def can_index_in_search?
      self.class.searchable_instances.find_by_id(self.id).present? && Whitehall.searchable_classes.include?(self.class)
    end

    def update_in_search_index
      if can_index_in_search?
        Whitehall::SearchIndex.add(self)
      end
    end

    def remove_from_search_index
      Whitehall::SearchIndex.delete(self)
    end

    def rummager_index
      :government
    end

    module ClassMethods
      def reindex_all
        searchable_instances
          .select { |instance| Whitehall.searchable_classes.include?(instance.class) }
          .each { |instance|  Whitehall::SearchIndex.add(instance) }
      end

      def searchable_instances
        searchable_options[:only].call(self)
      end

      def search_index
        Enumerator.new do |y|
          searchable_instances.find_each do |edition|
            y << edition.search_index
          end
        end
      end
    end
  end
end

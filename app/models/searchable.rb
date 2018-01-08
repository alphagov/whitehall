module Searchable
  extend ActiveSupport::Concern

  SEARCH_FIELDS = [
    :acronym,
    :attachments,
    :boost_phrases,
    :content,
    :content_id,
    :content_store_document_type,
    :description,
    :display_type,
    :detailed_format,
    :end_date,
    :format,
    :government_name,
    :id,
    :is_historic,
    :is_withdrawn,
    :is_political,
    :latest_change_note,
    :link,
    :metadata,
    :news_article_type,
    :operational_field,
    :organisation_state,
    :organisation_type,
    :organisations,
    :people,
    :public_timestamp,
    :publication_type,
    :release_timestamp,
    :search_format_types,
    :slug,
    :speech_type,
    :statistics_announcement_state,
    :start_date,
    :title,

    # "Policy area" is the newer name for "topic"
    # (https://www.gov.uk/government/topics)
    # "Topic" is the newer name for "specialist sector"
    # (https://www.gov.uk/topic)
    #
    # There are two ways for policy areas to wind up in rummager:
    # 1. Models directly ask for them in the class method call to `searchable`:
    #    in this case it is the responsibility of the subclasses to handle
    #    the naming clash if they are still using the older name
    # 2. Through the Edition::Topics and Edition::TopicalEvents concerns.
    #    These override #search_index and add to the policy_areas key.
    :policy_areas,

    # DID YOU MEAN: Topic?
    # See above: this should be renamed once the naming for policy areas is
    # consistent.
    :specialist_sectors,

    :world_locations,
  ]

  included do
    class_attribute :searchable_options
  end

  module ClassMethods
    def searchable(options)
      include Searchable::Mixin

      self.searchable_options = options.reverse_merge \
        format:         ->(o) { o.class.model_name.element },
        content_id:     ->(o) { o.try(:content_id) },
        index_after:    :save,
        unindex_after:  :destroy,
        only:           :all,
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
            ->(_) { value }
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
      content: 'indexable_content',
    }

    # Build the payload to pass to the search index
    def search_index
      SEARCH_FIELDS.reduce({}) do |result, name|
        value = searchable_options[name].call(self)
        key = KEY_MAPPING[name] || name.to_s
        result[key] = value unless value.nil?
        result
      end
    end

    def update_in_search_index
      Whitehall::SearchIndex.add(self) if can_index_in_search?
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
          .select { |instance| RummagerPresenters.searchable_classes.include?(instance.class) }
          .each { |instance| Whitehall::SearchIndex.add(instance) }
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

  def can_index_in_search?
    self.class.searchable_instances.find_by(id: self.id).present? && RummagerPresenters.searchable_classes.include?(self.class)
  end
end

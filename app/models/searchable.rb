module Searchable
  extend ActiveSupport::Concern

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

      [:title, :link, :content, :section, :subsection, :subsubsection, :format, :only, :boost_phrases, :description].each do |name|
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
      [:title, :link, :format, :content, :section, :subsection, :subsubsection, :boost_phrases, :description].inject({}) do |result, name|
        value = searchable_options[name].call(self)
        key = KEY_MAPPING[name] || name.to_s
        result[key] = value unless value.nil?
        result
      end
    end

    def update_in_search_index
      Rummageable.index(search_index, index)
    end

    def remove_from_search_index
      Rummageable.delete(searchable_options[:link].call(self), index)
    end

    def index
      is_a?(DetailedGuide) ? Whitehall.detailed_guidance_search_index_name : Whitehall.government_search_index_name
    end

    module ClassMethods
      def search_index
        searchable_options[:only].call(self).all.map(&:search_index)
      end
    end
  end
end

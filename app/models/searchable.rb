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
        only:           :scoped

      [:title, :link, :content, :format, :only].each do |name|
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

      set_callback searchable_options[:index_after], :after, :update_in_search_index if searchable_options[:index_after]
      set_callback searchable_options[:unindex_after], :after, :remove_from_search_index if searchable_options[:unindex_after]
    end
  end

  module Mixin
    extend ActiveSupport::Concern

    def search_index
      title, link, content, format =
        [:title, :link, :content, :format].map { |name| searchable_options[name].call(self) }

      {
        'title'             => title,
        'link'              => link,
        'indexable_content' => content,
        'format'            => format
      }
    end

    def update_in_search_index
      Rummageable.index(search_index)
    end

    def remove_from_search_index
      Rummageable.delete(searchable_options[:link].call(self))
    end

    module ClassMethods
      def search_index
        searchable_options[:only].call(self).all.map(&:search_index)
      end
    end
  end
end

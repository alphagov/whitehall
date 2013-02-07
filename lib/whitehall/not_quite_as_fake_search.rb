require 'whitehall/document_filter/filterer'
module Whitehall
  module NotQuiteAsFakeSearch
    class Rummageable
      def store
        Store.instance
      end
      def index(documents, index_name)
        store.add(documents, index_name)
      end

      def delete(link, index_name)
        store.delete(link, index_name)
      end

      # We don't call this, so leave it empty
      def amend(link, amendments, index_name)
      end

      # No impl seems neccessary
      def commit(index_name)
      end

      # No impl seems neccessary
      def validate_structure(hash, parents=[])
      end
    end

    class DocumentFilter < Whitehall::DocumentFilter::Filterer
      def store
        Store.instance
      end

      def default_index
        store.index(Whitehall.government_search_index_path)
      end

      def announcements_search
        @documents = apply_filters(filter_by_announcement_type(default_index[:all].values))
      end

      def publications_search
        @documents = apply_filters(filter_by_publication_type(default_index[:all].values))
      end

      def policies_search
        @documents = apply_filters(filter_by_policy(default_index[:all].values))
      end

      def documents
        apply_sort(Edition.where(id: @documents.map{ |d| d['id'] }).page(@page).per(@per_page))
      end

      def apply_filters(document_hashes)
        filter_by_relevant_to_local_government(
          filter_by_keywords(
            filter_by_date(
              filter_by_topics(
                filter_by_organisations(
                  document_hashes
                )
              )
            )
          )
        )
      end

      def filter_by_relevant_to_local_government(document_hashes)
        document_hashes.select { |document_hash| document_hash['relevant_to_local_government'] == relevant_to_local_government }
      end

      def filter_by_policy(document_hashes)
        document_hashes.select { |document_hash| document_hash['format'] == "policy" }
      end

      def filter_by_publication_type(document_hashes)
        if selected_publication_filter_option
          publication_type_ids = selected_publication_filter_option.publication_types.map(&:id)
          pre_filtered =
            if selected_publication_filter_option.edition_types.any?
              edition_types = selected_publication_filter_option.edition_types
              format = edition_types.first.underscore
              document_hashes.select { |document_hash| (document_hash['format'] == format) || (publication_type_ids.include? document_hash['publication_type']) }
            else
              document_hashes.select { |document_hash| publication_type_ids.include? document_hash['publication_type'] }
            end
          if selected_consultation_type_option
            pre_filtered.select { |document_hash| document_hash['display_type'] == selected_consultation_type_option }
          else
            pre_filtered
          end
        else
          document_hashes.select { |document_hash| ['publication', 'statistical_data_set', 'consultation'].include? document_hash['format'] }
        end
      end

      def filter_by_announcement_type(document_hashes)
        if selected_announcement_type_option
          pre_filtered =
            if selected_announcement_type_option.speech_types.present?
              document_hashes.select { |document_hash| selected_announcement_type_option.speech_types.map(&:id).include? document_hash['speech_type'] }
            elsif selected_announcement_type_option.news_article_types.present?
              document_hashes.select { |document_hash| selected_announcement_type_option.news_article_types.map(&:id).include? document_hash['news_article_type'] }
            else
              document_hashes
            end
          pre_filtered.select { |document_hash| formats_from_model_names(selected_announcement_type_option.edition_types).include? document_hash['format'] }
        else
          document_hashes.select { |document_hash| ["speech", "news_article", "fatality_notice"].include? document_hash['format'] }
        end
      end

      def filter_by_keywords(document_hashes)
        if keywords.any?
          keywords_regexp = /(#{keywords.map { |k| Regexp.escape(k) }.join('|')})/
          document_hashes.select { |document_hash| (document_hash['summary'] =~ keywords_regexp) || (document_hash['title'] =~ keywords_regexp) }
        else
          document_hashes
        end
      end

      def filter_by_topics(document_hashes)
        if selected_topics.any?
          document_hashes.select { |document_hash| (selected_topics.map(&:id) & document_hash['topics']).any? }
        else
          document_hashes
        end
      end

      def filter_by_organisations(document_hashes)
        if selected_organisations.any?
          document_hashes.select { |document_hash| (selected_organisations.map(&:id) & document_hash['organisations']).any? }
        else
          document_hashes
        end
      end

      def filter_by_date(document_hashes)
        if date.present? && direction.present?
          case direction
          when "before"
            document_hashes.select { |document_hash| document_hash['public_timestamp'] <= date }
          when "after"
            document_hashes.select { |document_hash| document_hash['public_timestamp'] >= date }
          else
            document_hashes
          end
        else
          document_hashes
        end
      end

      def apply_sort(documents)
        if direction.present?
          case direction
          when "before"
            documents.in_reverse_chronological_order
          when "after"
            documents.in_chronological_order
          when "alphabetical"
            documents.alphabetical
          else
            documents
          end
        else
          documents
        end
      end

    end

    class Store
      include Singleton

      def add(documents, index_name)
        docs = documents.is_a?(Hash) ? [documents] : documents
        docs.each do |document|
          document = document.stringify_keys
          index = self.index(index_name)
          index[:all][document['link']] = document
        end
      end

      def delete(link, index_name)
        index = self.index(index_name)
        index[:all].delete(link)
      end

      def index(index_name)
        initialize_indexes if @indexes.nil?
        initialize_index(index_name)
        @indexes[index_name]
      end

      def initialize_index(index_name)
        unless @indexes.has_key?(index_name)
          @indexes[index_name] = {all: {}}
        end
      end

      def initialize_indexes
        @indexes = {}
      end
    end
  end
end

module SyncChecker
  module Checks
    class TopicsCheck
      attr_reader :topic_content_id_map, :edition, :content_item

      def initialize(edition, topic_content_id_map = TopicContentIdMap.fetch)
        @topic_content_id_map = topic_content_id_map
        @edition = edition
      end

      def call(response)
        failures = []
        if response.response_code == 200
          @content_item = JSON.parse(response.body)
          if run_check?
            failures << check_parent
            failures << check_topics
          end
        end
        failures.flatten.compact
      end

    private

      def run_check?
        %w(gone redirect).exclude?(content_item["schema_name"])
      end

      def check_parent
        return if links_parent.nil? && parent_base_path.nil?
        return "expected links#parent but it isn't present" if links_parent.nil? && parent_base_path.present?
        return "links#parent is present but shouldn't be" if links_parent.present? && parent_base_path.blank?

        parent_content_id = links_parent["content_id"]
        expected_parent_content_id = topic_content_id_map["/topic/#{edition.primary_specialist_sector_tag}"]
        if parent_content_id != expected_parent_content_id
          "expected parent#content_id to be '#{expected_parent_content_id}' but got '#{parent_content_id}'"
        end
      end

      def check_topics
        return if topic_base_paths.empty? && links_topics.nil?
        return "expected links#topics but it isn't present" if links_topics.nil? && topic_base_paths.any?
        return "links#topics are present but shouldn't be" if links_topics.present? && topic_base_paths.empty?
        check_for_missing_topics + check_for_unexpected_topics
      end

      def check_for_missing_topics
        expected_content_ids
          .reject { |content_id| links_topics_content_ids.include?(content_id)}
          .map { |missing_content_id| "links#topics should contain '#{missing_content_id}' but doesn't" }
      end

      def check_for_unexpected_topics
        links_topics_content_ids
          .reject { |content_id| expected_content_ids.include?(content_id)}
          .map { |unexpected_content_id| "links#topics contains '#{unexpected_content_id}' but shouldn't" }
      end

      def topic_base_paths
        edition.specialist_sector_tags.map { |tag| "/topic/#{tag}" }
      end

      def expected_content_ids
        topic_content_id_map.slice(*topic_base_paths).values
      end

      def links_parent
        parent_element = content_item["links"]["parent"]
        parent_element ? parent_element[0] : nil
      end

      def links_topics
        content_item["links"]["topics"]
      end

      def links_topics_content_ids
        links_topics.map { |topic_element| topic_element["content_id"] }
      end

      def parent_base_path
        edition.primary_specialist_sector_tag
      end
    end
  end
end

require_relative '../../lib/whitehall'

module SyncChecker
  class DraftTopicContentIds
    def self.fetch
      @draft_content_ids ||= begin
        Whitehall.publishing_api_v2_client
          .get_linkables(document_type: 'topic')
          .map(&:with_indifferent_access)
          .select { |linkable| linkable[:publication_state] == 'draft' }
          .map { |linkable| linkable[:content_id] }
      end
    end
  end
end

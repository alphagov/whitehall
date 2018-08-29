require_relative '../../lib/whitehall'

module SyncChecker
  class DraftTopicContentIds
    def self.fetch
      @fetch ||= begin
        Services.publishing_api
          .get_linkables(document_type: 'topic')
          .map(&:with_indifferent_access)
          .select { |linkable| linkable[:publication_state] == 'draft' }
          .map { |linkable| linkable[:content_id] }
      end
    end
  end
end

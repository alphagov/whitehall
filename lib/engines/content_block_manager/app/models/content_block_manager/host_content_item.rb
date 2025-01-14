module ContentBlockManager
  class HostContentItem < Data.define(
    :title,
    :base_path,
    :document_type,
    :publishing_organisation,
    :publishing_app,
    :last_edited_by_editor,
    :last_edited_at,
    :unique_pageviews,
    :instances,
    :host_content_id,
  )

    DEFAULT_ORDER = "-unique_pageviews".freeze

    class << self
      def for_document(content_block_document, page: nil, order: nil)
        api_response = Services.publishing_api.get_host_content_for_content_id(
          content_block_document.content_id,
          {
            page:,
            order: order || DEFAULT_ORDER,
          }.compact,
        ).parsed_content

        editor_uuids = api_response["results"].map { |c| c["last_edited_by_editor_id"] }.compact.uniq
        editors = editor_uuids.present? ? ContentBlockManager::SignonUser.with_uuids(editor_uuids) : []

        items = api_response["results"].map do |record|
          from_api_record(record, editors)
        end

        ContentBlockManager::HostContentItem::Items.new(
          items:,
          total: api_response["total"],
          total_pages: api_response["total_pages"],
          rollup: rollup(api_response),
        )
      end

    private

      def rollup(api_response)
        ContentBlockManager::HostContentItem::Items::Rollup.new(
          views: api_response["rollup"]["views"],
          locations: api_response["rollup"]["locations"],
          instances: api_response["rollup"]["instances"],
          organisations: api_response["rollup"]["organisations"],
        )
      end

      def from_api_record(record, editors)
        new(
          title: record["title"],
          base_path: record["base_path"],
          document_type: record["document_type"],
          publishing_organisation: record["primary_publishing_organisation"],
          publishing_app: record["publishing_app"],
          last_edited_by_editor: editors.find { |editor| editor.uid == record["last_edited_by_editor_id"] },
          last_edited_at: record["last_edited_at"],
          unique_pageviews: record["unique_pageviews"],
          instances: record["instances"],
          host_content_id: record["host_content_id"],
        )
      end
    end

    def last_edited_at
      Time.zone.parse(super)
    end
  end
end

module ContentBlockManager
  class HostContentItem < Data.define(
    :title,
    :base_path,
    :document_type,
    :publishing_organisation,
    :publishing_app,
    :last_edited_by_editor_id,
    :last_edited_at,
    :unique_pageviews,
    :host_content_id,
  )

    def last_edited_at
      Time.zone.parse(super)
    end
  end
end

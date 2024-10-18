module ContentBlockManager
  class HostContentItem < Data.define(
    :title,
    :base_path,
    :document_type,
    :publishing_organisation,
    :publishing_app,
    :last_edited_by_editor_id,
    :last_edited_at,
  )

    def last_edited_at
      Time.zone.parse(super)
    end
  end
end

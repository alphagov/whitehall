module ContentObjectStore
  class HostContentItem < Data.define(:content_id, :title, :base_path, :document_type, :publishing_organisation, :publishing_app)
  end
end

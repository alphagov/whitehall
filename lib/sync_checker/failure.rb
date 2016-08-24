module SyncChecker
  Failure = Struct.new(:document_id, :edition_id, :locale, :content_store, :errors)
end

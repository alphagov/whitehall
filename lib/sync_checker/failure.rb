module SyncChecker
  class Failure
    attr_reader :document_id, :edition_id, :locale, :errors
    def initialize(document_id, edition_id, locale, errors = [])
      @errors = errors
      @document_id = document_id
      @locale = locale
      @edition_id = edition_id
    end
  end
end

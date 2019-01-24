module DataHygiene
  class ChangeNoteRemover
    def initialize(content_id, locale, change_note_search, dry_run:)
      @content_id = content_id
      @locale = locale
      @change_note_search = change_note_search
      @dry_run = dry_run
    end

    def call
      raise DataHygiene::ChangeNoteNotFound.new unless edition
      return edition if dry_run

      destroy_edition_change_note
      represent_downstream

      edition
    end

    def self.call(*args)
      new(*args).call
    end

    private_class_method :new

  private

    attr_reader :content_id, :locale, :change_note_search, :dry_run

    def document
      @document ||= Document.find_by(content_id: content_id)
    end

    def find_edition_with_change_note
      fuzzy_match = FuzzyMatch.new(document.editions, read: :change_note)
      fuzzy_match.find(change_note_search, must_match_at_least_one_word: true)
    end

    def edition
      @edition ||= find_edition_with_change_note
    end

    def destroy_edition_change_note
      edition[:minor_change] = true
      edition.change_note = nil
      edition.save!(validate: false)
    end

    def represent_downstream
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end

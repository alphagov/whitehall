module DataHygiene
  class ChangeNoteRemover
    def initialize(content_id, locale, change_note_search, dry_run:)
      @content_id = content_id
      @locale = locale
      @change_note_search = change_note_search
      @dry_run = dry_run
    end

    def call
      raise DataHygiene::ChangeNoteNotFound unless edition
      return edition if dry_run

      downgrade_edition_change_note
      represent_downstream

      edition
    end

    def self.call(...)
      new(...).call
    end

    private_class_method :new

  private

    attr_reader :content_id, :locale, :change_note_search, :dry_run

    def document
      @document ||= Document.find_by(content_id:)
    end

    def editions
      @editions ||= document.editions
    end

    def edition
      @edition ||= find_edition_with_change_note
    end

    def find_edition_with_change_note
      fuzzy_match = FuzzyMatch.new(editions, read: :change_note)
      fuzzy_match.find(change_note_search, must_match_at_least_one_word: true)
    end

    def previous_major_change
      editions.where(minor_change: false).where("id < ?", edition.id).last
    end

    def downgrade_edition_change_note
      edition[:minor_change] = true
      edition.change_note = nil
      edition.major_change_published_at = previous_major_change.try(:major_change_published_at)
      edition.save!(validate: false)
    end

    def represent_downstream
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end
  end
end

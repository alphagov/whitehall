class EditionPublisher
  attr_reader :edition, :options, :subscribers

  def initialize(edition, options={})
    @edition = edition
    @options = options
    @subscribers = options.delete(:subscribers) || default_subscribers
  end

  def perform!
    if can_perform?
      prepare_edition
      edition.publish!
      edition.archive_previous_editions!
      subscribers.each { |subscriber| subscriber.edition_published(edition, options) }
      true
    end
  end

  def can_perform?
    !failure_reason
  end

  def failure_reason
    @failure_reason ||= if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    elsif !edition.can_publish?
      "An edition that is #{edition.current_state} cannot be published"
    elsif edition.scheduled_publication.present? && Time.zone.now < edition.scheduled_publication
      "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before"
    end
  end

  def default_subscribers
    [Edition::AuthorNotifier, Whitehall::GovUkDelivery::Notifier, Edition::SearchIndexer]
  end

private

  def prepare_edition
    edition.access_limited  = false
    edition.major_change_published_at = Time.zone.now unless edition.minor_change?
    edition.make_public_at(edition.major_change_published_at)
    edition.increment_version_number
  end
end

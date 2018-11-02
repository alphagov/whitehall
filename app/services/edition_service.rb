# Abstract base class for edition services
class EditionService
  attr_reader :edition, :options, :notifier

  def initialize(edition, options = {})
    @edition = edition
    @notifier = options.delete(:notifier)
    @options = options
  end

  def perform!
    if can_perform?
      ActiveRecord::Base.transaction do
        prepare_edition
        fire_transition!
        update_publishing_api! unless is_whitehall_corp_info_page?
      end
      notify!
      true
    end
  end

  def can_perform?
    !failure_reason
  end

  def can_transition?
    edition.public_send("can_#{verb}?")
  end

  def failure_reason
    raise NotImplementedError.new("You must implement failure method.")
  end

  def verb
    raise NotImplementedError.new("You must implement verb method.")
  end

  def past_participle
    "#{verb}ed".humanize.downcase
  end

private

  def is_whitehall_corp_info_page?
    edition.type == 'CorporateInformationPage' &&
      edition.rendering_app == Whitehall::RenderingApp::WHITEHALL_FRONTEND
  end

  def notify!
    # reload the edition to strip the LocalisedModel, as this can
    # cause problems later with localisation.
    #
    # If we can get rid of LocalisedModel, this can be removed.
    notifier && notifier.publish(verb, edition.reload, options)
  end

  def update_publishing_api!
    ServiceListeners::PublishingApiPusher
      .new(edition.reload)
      .push(event: verb, options: options)
  end

  def prepare_edition
    # Noop by default
  end

  def fire_transition!
    edition.public_send("#{verb}!")
  end
end

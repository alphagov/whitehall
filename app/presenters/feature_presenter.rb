FeaturePresenter = Struct.new(:feature) do
  include ActiveModel::Conversion

  def self.model_name
    Feature.model_name
  end

  def persisted?
    true
  end

  delegate :id, to: :feature

  delegate :document, to: :feature

  def edition
    document.live_edition
  end

  delegate :topical_event, to: :feature

  delegate :offsite_link, to: :feature

  def image(size)
    feature.image.url(size || :s630)
  end

  delegate :alt_text, to: :feature

  def time_stamp
    if feature.document
      edition.public_timestamp
    elsif topical_event
      topical_event.start_date
    elsif offsite_link
      offsite_link.date
    end
  end

  def display_type_key
    if offsite_link
      offsite_link.link_type
    else
      edition.display_type_key
    end
  end

  def public_path
    if topical_event
      Whitehall.url_maker.topical_event_path(topical_event)
    elsif offsite_link
      offsite_link.url
    elsif edition.translatable?
      Whitehall.url_maker.public_document_path(edition, locale: feature.locale)
    else
      ::I18n.with_locale ENGLISH_LOCALE_CODE do
        Whitehall.url_maker.public_document_path(edition)
      end
    end
  end

  def title
    if topical_event
      topical_event.name
    elsif offsite_link
      offsite_link.title
    else
      edition.title
    end
  end

  def summary
    if topical_event
      topical_event.description
    elsif offsite_link
      offsite_link.summary
    else
      edition.summary
    end
  end
end

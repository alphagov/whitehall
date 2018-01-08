class FeaturePresenter < Struct.new(:feature)
  include ActiveModel::Conversion

  def self.model_name
    Feature.model_name
  end

  def persisted?
    true
  end

  def id
    feature.id
  end

  def document
    feature.document
  end

  def edition
    document.published_edition
  end

  def topical_event
    feature.topical_event
  end

  def offsite_link
    feature.offsite_link
  end

  def image(size)
    feature.image.url(size || :s630)
  end

  def alt_text
    feature.alt_text
  end

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
    else
      if edition.translatable?
        Whitehall.url_maker.public_document_path(edition, locale: feature.locale)
      else
        ::I18n.with_locale Locale::ENGLISH_LOCALE_CODE do
          Whitehall.url_maker.public_document_path(edition)
        end
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

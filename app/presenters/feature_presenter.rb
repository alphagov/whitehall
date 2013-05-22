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

  def image(size)
    feature.image.url(size || :s630)
  end

  def alt_text
    feature.alt_text
  end

  def time_stamp
    feature.document ? edition.public_timestamp : topical_event.start_date
  end

  def display_type_key
    edition.display_type_key
  end

  def public_path
    if topical_event
      Whitehall.url_maker.topical_event_path(topical_event)
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
    else
      edition.title
    end
  end

  def summary
    if topical_event
      topical_event.description
    else
      edition.summary
    end
  end

end

class DocumentListExportPresenter
  attr_accessor :edition

  def initialize(edition)
    @edition = edition
  end

  def row
    format_elements(row_data)
  end

  def self.header_row
    [
      'Public URL',
      'Admin URL',
      'Title',
      'Lead organisations',
      'Supporting organisations',
      'First published',
      'First published on GOV.UK',
      'Published by',
      'Last updated',
      'Content type',
      'Content sub-type',
      'State',
      'Attachments',
      'Policies',
      'Specialist sectors',
      'Collections',
      'Can have history-mode',
      'History-mode applied',
      'Primary language',
      'Translations available',
      'Summary',
    ]
  end

  def row_data
    [
      public_url,
      admin_url,
      edition.title,
      lead_organisations,
      supporting_organisations,
      edition.first_published_at,
      first_published_on_govuk,
      edition.published_by.try(:name),
      edition.updated_at,
      content_type,
      sub_content_type,
      state,
      attachment_types,
      policies,
      specialist_sectors,
      collections,
      edition.political?,
      edition.historic?,
      primary_language,
      translations_available,
      edition.summary,
    ]
  end

  def public_url
    Whitehall.url_maker.public_document_url(edition)
  end

  def admin_url
    Whitehall.url_maker.admin_edition_url(edition)
  end

  def first_published_on_govuk
    edition.publication_audit_entry.try(:created_at)
  end

  def content_type
    edition.type.titleize
  end

  def sub_content_type
    case edition
    when NewsArticle
      edition.news_article_type.singular_name
    when Publication
      edition.publication_type.singular_name
    when Speech
      edition.speech_type.singular_name
    when CorporateInformationPage
      edition.corporate_information_page_type.slug.underscore.humanize
    else
      'N/A'
    end
  end

  def lead_organisations
    if edition.is_a?(CorporateInformationPage)
      edition.owning_organisation.name
    else
      edition.lead_organisations.map(&:name)
    end
  end

  def supporting_organisations
    edition.supporting_organisations.map(&:name) if edition.respond_to? :supporting_organisations
  end

  def state
    if edition.force_published?
      "force published"
    elsif edition.unpublishing
      "unpublished"
    else
      edition.state
    end
  end

  def policies
    if edition.can_be_related_to_policies?
      edition.policies.map(&:title)
    end
  end

  def specialist_sectors
    edition.specialist_sectors.pluck(:tag)
  end

  def attachment_types
    return unless edition.respond_to? :attachments
    edition.attachments.map do |att|
      case att
      when FileAttachment
        att.filename
      when ExternalAttachment
        att.external_url
      when HtmlAttachment
        att.title
      end
    end
  end

  def collections
    edition.document_collections.map(&:title) if edition.respond_to? :document_collections
  end

  def format_elements(data)
    data.map do |elem|
      case elem
      when Array
        elem.join(' | ')
      when Time
        # YYYY-MM-DD hh:mm:ss, which seems to be best understood by spreadsheets.
        elem.to_formatted_s(:db)
      when true
        'yes'
      when false
        'no'
      else
        elem
      end
    end
  end

  def primary_language
    edition.primary_language_name
  end

  def translations_available
    # we don't use available_in_multiple_languages? here because it
    # returns true for editions with one english version and only one
    # other language version; which is not exactly what we want here
    return 'none' unless edition.translated_locales.count > 1

    edition.
      translated_locales.
      reject { |locale_code| locale_code.to_s == edition.primary_locale.to_s }.
      sort_by(&:to_s).
      map { |locale_code| Locale.new(locale_code).english_language_name }
  end

end

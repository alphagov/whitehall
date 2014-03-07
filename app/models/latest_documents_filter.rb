class LatestDocumentsFilter
  attr_reader :subject, :options

  def self.for_subject(subject, options = {})
    case subject
    when Classification
      ClassificationFilter.new(subject, options)
    when Organisation
      OrganisationFilter.new(subject, options)
    when WorldLocation
      WorldLocationFilter.new(subject, options)
    end
  end

  def initialize(subject, options = {})
    @subject = subject
    @options = options
  end

  def documents
    documents_source.page(page_number).per(page_size)
  end

private
  def documents_source
    raise NotImplementedError, 'you must provide #documents_source implementation in your LatestDocumentsFilter subclass'
  end

  def page_number
    options.fetch(:page, 0)
  end

  def page_size
    options.fetch(:per_page, 40)
  end

  class OrganisationFilter < LatestDocumentsFilter
  private
    def documents_source
      subject.published_editions
             .in_reverse_chronological_order
             .with_translations(I18n.locale)
    end
  end

  class ClassificationFilter < LatestDocumentsFilter
  private
    def documents_source
      subject.published_editions
             .in_reverse_chronological_order
             .without_editions_of_type(WorldLocationNewsArticle)
             .with_translations(I18n.locale)
    end
  end

  class WorldLocationFilter < LatestDocumentsFilter
  private
    def documents_source
      subject.published_editions
             .in_reverse_chronological_order
             .with_translations(I18n.locale)
    end
  end
end

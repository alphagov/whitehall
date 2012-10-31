class Whitehall::Uploader::PublicationRow
  attr_reader :row

  def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout))
    @row = row
    @line_number = line_number
    @logger = logger
    @attachment_cache = attachment_cache
  end

  def cleanup
  end

  def title
    row['title']
  end

  def summary
    row['summary']
  end

  def body
    row['body']
  end

  def legacy_url
    row['old_url']
  end

  def publication_date
    PublicationDateParser.parse(row['publication_date'], @logger, @line_number)
  end

  def publication_type
    PublicationTypeFinder.find(row['publication_type'], @logger, @line_number)
  end

  def related_policies
    PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"], @logger, @line_number)
  end

  def organisations
    OrganisationFinder.find(row['organisation'], @logger, @line_number)
  end

  def document_series
    DocumentSeriesFinder.find(row['document_series'], @logger, @line_number)
  end

  def ministerial_roles
    MinisterialRoleFinder.find(publication_date, row['minister_1'], row['minister_2'], @logger, @line_number)
  end

  def attachments
    if @attachments.nil?
      @attachments = 1.upto(50).map do |number|
        AttachmentDownloader.build(row["attachment_#{number}_title"], row["attachment_#{number}_url"], @attachment_cache, @logger, @line_number)
      end.compact
      AttachmentMetadataBuilder.build(@attachments.first, row["order_url"], row["ISBN"], row["URN"], row["command_paper_number"])
    end
    @attachments
  end

  def alternative_format_provider
    organisations.first
  end

  def attributes
    [:title, :summary, :body, :publication_date, :publication_type,
     :related_policies, :organisations, :document_series,
     :ministerial_roles, :attachments, :alternative_format_provider].map.with_object({}) do |name, result|
      result[name] = __send__(name)
    end
  end

  class PublicationDateParser
    def self.parse(date, logger, line_number)
      begin
        if date =~ /^\d{1,2}\-[A-Za-z]{3}\-\d{2}/
          Date.strptime(date, '%d-%b-%y')
        elsif date =~ /\d{4}\-\d{2}\-\d{2}/
          Date.strptime(date, '%Y-%m-%d')
        else
          Date.strptime(date, '%m/%d/%Y')
        end
      rescue
        logger.warn "Row #{line_number}: Unable to parse the date '#{date}'"
      end
    end
  end

  class PublicationTypeFinder
    PublicationTypeSpecialCases = {
      'Impact assessment' => PublicationType::ImpactAssessment
    }
    def self.find(slug, logger, line_number)
      type = PublicationType.find_by_slug(slug) || PublicationTypeSpecialCases[slug]
      logger.warn "Row #{line_number}: Unable to find Publication type with slug '#{slug}'" unless type
      type
    end
  end

  class PoliciesFinder
    def self.find(*slugs, logger, line_number)
      slugs = slugs.reject { |slug| slug.blank? }.uniq
      slugs.collect do |slug|
        if document = Document.find_by_slug(slug)
          if document.published_edition
            document.published_edition
          elsif document.latest_edition
            document.latest_edition
          end
        else
          logger.warn "Row #{line_number}: Unable to find Document with slug '#{slug}'"
          nil
        end
      end.compact
    end
  end

  class OrganisationFinder
    def self.find(name_or_slug, logger, line_number)
      return [] if name_or_slug.blank?
      organisation = Organisation.find_by_name(name_or_slug) || Organisation.find_by_slug(name_or_slug)
      logger.warn "Row #{line_number}: Unable to find Organisation named '#{name_or_slug}'" unless organisation
      [organisation].compact
    end
  end

  class DocumentSeriesFinder
    def self.find(slug, logger, line_number)
      return if slug.blank?
      document_series = DocumentSeries.find_by_slug(slug)
      logger.warn "Row #{line_number}: Unable to find Document series with slug '#{slug}'" unless document_series
      document_series
    end
  end

  class MinisterialRoleFinder
    def self.find(date, *slugs, logger, line_number)
      slugs = slugs.reject { |slug| slug.blank? }

      people = slugs.map do |slug|
        person = Person.find_by_slug(slug)
        logger.warn "Unable to find Person with slug '#{slug}'" unless person
        person
      end.compact

      people.map do |person|
        ministerial_roles = person.ministerial_roles_at(date)
        logger.warn "Row #{line_number}: Unable to find a Role for '#{person.slug}' at '#{date}'" if ministerial_roles.empty?
        ministerial_roles
      end.flatten
    end
  end

  class AttachmentDownloader
    def self.build(title, url, cache, logger, line_number)
      return unless title.present? && url.present?
      file = cache.fetch(url)
      attachment_data = AttachmentData.new(file: file)
      attachment = Attachment.new(title: title, attachment_data: attachment_data)
      attachment.build_attachment_source(url: url)
      attachment
    rescue Whitehall::Uploader::AttachmentCache::RetrievalError => e
      logger.error "Row #{line_number}: Unable to fetch attachment '#{url}' - #{e.to_s}"
      nil
    end
  end

  class AttachmentMetadataBuilder
    def self.build(attachment, order_url, isbn, unique_reference, command_paper_number)
      return unless attachment && (order_url || isbn || unique_reference || command_paper_number)
      attachment.order_url = order_url
      attachment.isbn = isbn
      attachment.unique_reference = unique_reference
      attachment.command_paper_number = command_paper_number
    end
  end
end

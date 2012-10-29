class Whitehall::Uploader::PublicationRow
  attr_reader :row

  def initialize(row, line_number, logger = Logger.new($stdout))
    @row = row
    @line_number
    @logger = logger
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
    PublicationTypeFinder.find(row['pub type'], @logger, @line_number)
  end

  def related_policies
    PoliciesFinder.find(row['policy 1'], row['policy 2'], row['policy 3'], @logger, @line_number)
  end

  def organisations
    OrganisationFinder.find(row['org'], @logger, @line_number)
  end

  def document_series
    DocumentSeriesFinder.find(row['doc series'], @logger, @line_number)
  end

  def ministerial_roles
    MinisterialRoleFinder.find(publication_date, row['minister 1'], row['minister 2'], @logger, @line_number)
  end

  def attachments
    1.upto(50).map do |number|
      if title = row["attachment #{number} title"]
        if file = download_from_url(row["attachment #{number} url"])
          attachment_data = AttachmentData.new(file: file)
          attachment = Attachment.new(title: title, attachment_data: attachment_data)
          attachment.build_attachment_source(url: row["attachment #{number} url"])
          attachment
        end
      end
    end.compact
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

  def download_from_url(url)
    uri = URI.parse(url)
    @logger.info "Fetching #{url}"
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPOK)
      result = Dir.mktmpdir do |dir|
        filename = File.basename(uri.path)
        File.open(File.join(dir, filename), 'w', encoding: 'ASCII-8BIT') do |file|
          file.write(response.body)
        end
        File.open(File.join(dir, filename), 'r')
      end
    else
      @logger.error "Unable to fetch attachment '#{url}' for '#{title}', got response status #{response.code}.'"
      nil
    end
  rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
    @logger.error "Unable to fetch attachment '#{url}' for '#{title}' due to #{e.class}: '#{e.message}'"
    nil
  end

  class PublicationDateParser
    def self.parse(date, logger, line_number)
      begin
        Date.strptime(date, '%m/%d/%Y')
      rescue ArgumentError
        logger.warn "Row #{line_number}: Unable to parse the date '#{date}'"
      end
    end
  end

  class PublicationTypeFinder
    PublicationTypeMap = {
      'circulars-letters-and-bulletins' => PublicationType::CircularLetterOrBulletin,
      'corporate-reports'               => PublicationType::CorporateReport,
      'foi-releases'                    => PublicationType::FoiRelease,
      'forms'                           => PublicationType::Form,
      'guidance'                        => PublicationType::Guidance,
      'Impact assessment'               => PublicationType::ImpactAssessment,
      'impact-assessments'              => PublicationType::ImpactAssessment,
      'independent-reports'             => PublicationType::IndependentReport,
      'policy-papers'                   => PublicationType::PolicyPaper,
      'promotional-material'            => PublicationType::PromotionalMaterial,
      'research-and-analysis'           => PublicationType::ResearchAndAnalysis,
      'statistics'                      => PublicationType::Statistics,
      'transparency-data'               => PublicationType::TransparencyData
    }
    def self.find(slug, logger, line_number)
      type = PublicationTypeMap[slug]
      logger.warn "Row #{line_number}: Unable to find Publication type with slug '#{slug}'" unless type
      type
    end
  end

  class PoliciesFinder
    def self.find(*slugs, logger, line_number)
      slugs = slugs.reject { |slug| slug.blank? }
      slugs.collect do |slug|
        if document = Document.find_by_slug(slug)
          if document.published_edition
            document.published_edition
          else
            logger.warn "Row #{line_number}: Unable to find a published edition for the Document with slug '#{slug}'"
            nil
          end
        else
          logger.warn "Row #{line_number}: Unable to find Document with slug '#{slug}'"
          nil
        end
      end.compact
    end
  end

  class OrganisationFinder
    def self.find(name, logger, line_number)
      return [] if name.blank?
      organisation = Organisation.find_by_name(name)
      logger.warn "Row #{line_number}: Unable to find Organisation named '#{name}'" unless organisation
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
        logger.warn "Row #{line_number}: Unable to find a Role for '#{person.slug}' at '#{date}'/" if ministerial_roles.empty?
        ministerial_roles
      end.flatten
    end
  end
end

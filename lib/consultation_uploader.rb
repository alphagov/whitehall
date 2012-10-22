require 'csv'

class ConsultationUploader
  def initialize(options = {})
    @csv_data = options[:csv_data]
    @creator = options[:import_as] || User.find_by_name!("Automatic Data Importer")
    @logger = options[:logger] || Logger.new($stderr)
  end

  def upload
    data = CSV.new(@csv_data, headers: true, encoding: "UTF-8")
    data.each do |row|
      RowUploader.new(row, @creator, @logger).upload
    end
  end

  class UnavailableAttachment < RuntimeError; end

  class RowUploader
    attr_reader :row

    def initialize(row, creator, logger)
      @row = row
      @creator = creator
      @logger = logger
    end

    def upload
      Consultation.connection.transaction do
        if already_uploaded?
          @logger.warn("Document '#{source_url}' '#{title}' already uploaded, skipping")
          return
        end

        opening_date = Date.strptime(row['opening_date'], "%m/%d/%Y")
        closing_date = Date.strptime(row['closing_date'], "%m/%d/%Y")

        if organisation.nil?
          @logger.warn "Unable to find organisation '#{row['organisation']}' for '#{title}', skipping"
          return
        end

        if [row['minister 1'], row['minister 2']].any?(&:present?)
          raise "importing ministerial roles not implemented"
        end

        consultation = Consultation.new(
          title: title,
          summary: summary,
          body: body,
          opening_on: opening_date,
          closing_on: closing_date,
          related_policies: policies,
          organisations: [organisation],
          response: response,
          creator: @creator,
          alternative_format_provider: organisation,
          attachments: fetch_and_create_attachments('attachment')
        )
        consultation.save!
        DocumentSource.create!(document: consultation.document, url: row['old_url'])
      end
    rescue ActiveRecord::RecordInvalid, UnavailableAttachment => e
      @logger.error "Unable to upload '#{title}' because #{e}"
    end

  private
    def response
      attachments = fetch_and_create_attachments('response')
      if attachments.any? || response_date.present?
        Response.new(
          published_on: response_date,
          attachments: attachments
        )
      else
        nil
      end
    end

    def response_date
      if row['response date'].present?
        Date.strptime(row['response date'], "%m/%d/%Y")
      end
    end

    def title
      row['title']
    end

    def summary
      make_site_relative_links_absolute(row['summary'])
    end

    def body
      make_site_relative_links_absolute(row['body'])
    end

    def make_site_relative_links_absolute(govspeak)
      govspeak.gsub(%r{\[([^\]]*)\]\((/[^)]*)\)}, "[\\1](#{organisation.url}\\2)")
    end

    def source_url
      row['old_url']
    end

    def organisation
      @organisation ||= Organisation.find_by_name(row['organisation'])
    end

    def policies
      policy_slugs = [row['policy 1'], row['policy 2'], row['policy 3'], row['policy 4']]
      policy_slugs.map do |slug|
        next if slug.blank?
        doc = Document.find_by_slug(slug)
        if doc
          doc.published_edition
        else
          @logger.warn "Unable to find policy '#{slug}' for '#{row['title']}'"
          nil
        end
      end.compact
    end

    def fetch_and_create_attachments(prefix)
      row.headers.grep(%r{#{prefix}_\d+$}).select { |h| row[h].present? }.map do |header|
        fetch_and_create_attachment(row[header], row["#{header}_title"])
      end
    end

    def fetch_and_create_attachment(url, attachment_title)
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      Dir.mktmpdir do |dir|
        filename = File.basename(uri.path)
        File.open(File.join(dir, filename), 'w') do |file|
          file.write(response.body)
          Attachment.create!(file: file, title: attachment_title)
        end
      end
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
      raise UnavailableAttachment, "Unable to fetch attachment '#{url}' due to #{e.class}: '#{e.message}'", caller
    end

    def already_uploaded?
      DocumentSource.find_by_url(row['old_url']).present?
    end
  end
end
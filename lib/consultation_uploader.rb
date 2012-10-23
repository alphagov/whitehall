require 'csv'

class ConsultationUploader
  def initialize(options = {})
    @csv_data = options[:csv_data]
    @creator = options[:import_as] || User.find_by_name!("Automatic Data Importer")
    @logger = options[:logger] || Logger.new($stdout)
  end

  def upload
    data = CSV.new(read_and_validate_input(@csv_data), headers: true)
    data.each do |row|
      RowUploader.new(row, @creator, @logger).upload
    end
  end

  def csv_data
    validate_encoding()
  end

  def read_and_validate_input(csv_data)
    csv_string = csv_data.respond_to?(:read) ? csv_data.read : csv_data
    if ! csv_string.valid_encoding?
      raise InvalidEncoding, "Invalid character encoding in CSV input", caller
    end
    csv_string
  end

  class UnavailableAttachment < RuntimeError; end
  class InvalidEncoding < RuntimeError; end

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
        @logger.info("\nBuilding '#{title}'...")
        @logger.info("  (originally scraped from #{source_url})")

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
        response_description = if consultation.response.present?
          " and a response with #{consultation.response.attachments.count} attachments"
        end
        @logger.info("#{consultation.id}: created '#{title}' with #{consultation.attachments.count} attachments" + response_description.to_s)
        DocumentSource.create!(document: consultation.document, url: source_url)
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
      end.compact
    end

    def fetch_and_create_attachment(url, attachment_title)
      uri = URI.parse(url)
      @logger.info "Fetching #{url}"
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPOK)
        attachment = Dir.mktmpdir do |dir|
          filename = File.basename(uri.path)
          File.open(File.join(dir, filename), 'w', encoding: 'ASCII-8BIT') do |file|
            file.write(response.body)
            if attachment_title.blank?
              attachment_title = "Unknown"
              @logger.warn "Attachment #{url} missing a title, set to '#{attachment_title}'"
            end
            attachment = Attachment.create!(title: attachment_title)
            attachment.create_attachment_data!(file: file)
            attachment
          end
        end
        AttachmentSource.create!(attachment: attachment, url: url)
        @logger.info "Got #{human_readable_size(response.body.size)} to #{attachment.file.path}"
        attachment
      else
        @logger.error "Unable to fetch attachment '#{url}' for '#{title}', got response status #{response.code}.'"
        nil
      end
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
      @logger.error "Unable to fetch attachment '#{url}' for '#{title}' due to #{e.class}: '#{e.message}'"
      nil
    end

    def human_readable_size(bytes)
      count = 0
      while bytes >= 1024 and count < 4
        bytes /= 1024.0
        count += 1
      end
      format("%.1f", bytes) + %w(B K M G T)[count]
    end

    def already_uploaded?
      DocumentSource.find_by_url(row['old_url']).present?
    end
  end
end

module DataHygiene
  class PublishingApiHtmlAttachmentRedirector
    def initialize(content_id, destination, dry_run:)
      @content_id = content_id
      @destination = destination
      @dry_run = dry_run
    end

    def call
      if document && !unpublished_or_withdrawn
        raise DataHygiene::EditionNotUnpublished
      end
      raise DataHygiene::HtmlAttachmentsNotFound unless html_attachments.any?
      return dry_run_results if dry_run

      send_redirects_to_publishing_api
    end

    def self.call(...)
      new(...).call
    end

    private_class_method :new

  private

    attr_reader :content_id, :destination, :dry_run

    def document
      @document ||= Document.find_by(content_id:)
    end

    def last_edition
      @last_edition ||= document.editions.last
    end

    def unpublished_or_withdrawn
      last_edition.unpublished? || last_edition.withdrawn?
    end

    def html_attachments
      @html_attachments ||= document ? last_edition.html_attachments : [html_attachment]
    end

    def html_attachment
      @html_attachment ||= HtmlAttachment.find_by(content_id:)
    end

    def dry_run_results
      puts "Would have redirected: #{html_attachments.map(&:slug)}\nto #{destination}"
    end

    def send_redirects_to_publishing_api
      html_attachments.each do |attachment|
        PublishingApiRedirectWorker.new.perform(
          attachment.content_id,
          destination,
          attachment.locale || I18n.default_locale.to_s,
        )
      end
      puts "Redirected: #{html_attachments.map(&:slug)}\nto #{destination}"
    end
  end
end

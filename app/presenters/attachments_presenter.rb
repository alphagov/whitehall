class AttachmentsPresenter < Struct.new(:edition)
  class HtmlAttachment < Struct.new(:edition)
    include ActiveModel::Conversion
    include Rails.application.routes.url_helpers

    def html_version
      edition.html_version
    end

    def self.model_name
      ActiveModel::Name.new(Attachment)
    end

    %w(number_of_pages isbn unique_reference
       command_paper_number order_url price).each do |name|
      define_method(name.to_sym) { nil }
    end

    def file_extension
      'HTML'
    end

    def title
      html_version.title
    end

    def accessible?
      true
    end

    def pdf?
      false
    end

    def file_size
      html_version.body.size
    end

    def persisted?
      true
    end

    def url
      publication_attachment_path(edition.document, self)
    end

    def id
      html_version.slug
    end
  end

  def initialize(*args)
    super(*args)
  end

  def attachments
    return @attachments if @attachments
    @attachments = edition.attachments.dup
    if edition.respond_to?(:html_version) && edition.html_version.present?
      @attachments.unshift HtmlAttachment.new(edition)
    end
    @attachments
  end

  def length
    attachments.length
  end

  def any?
    attachments.any?
  end

  def first
    attachments.first
  end

  def more_than_one?
    remaining.any?
  end

  def remaining
    attachments[1..-1]
  end
end

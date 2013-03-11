class AttachmentsPresenter < Struct.new(:edition)
  class HtmlAttachment < Struct.new(:html_version)
    include ActiveModel::Conversion

    def self.model_name; ActiveModel::Name.new(Attachment); end

    def file_extension; 'HTML'; end
    def file_size; html_version.body.size; end
    def number_of_pages; nil; end
    def persisted?; false; end

    def url
      'http://gov.uk'
    end

    def title
      'title'
    end

    def isbn
      nil
    end

    def unique_reference
      nil
    end

    def command_paper_number
      nil
    end

    def order_url
      nil
    end

    def price
      nil
    end

    def accessible?
      true
    end

    def id
      nil
    end

    def pdf?
      false
    end
  end

  def initialize(*args)
    super(*args)
  end

  def attachments
    return @attachments if @attachments
    @attachments = edition.attachments.dup
    if edition.html_version.present?
      @attachments.unshift HtmlAttachment.new(edition.html_version)
    end
    @attachments
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

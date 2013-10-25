class Edition::EditorialRemarker
  attr_accessor :edition, :options

  def self.edition_published(edition, options)
    new(edition, options).save_remark!
  end

  def initialize(edition, options)
    @edition = edition
    @options = options
  end

  def save_remark!
    if author.present? && remark.present?
      edition.editorial_remarks.create(body: remark, author: author)
    end
  end

  def remark
    options[:remark]
  end

  def author
    options[:user]
  end
end

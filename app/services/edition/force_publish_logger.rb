class Edition::ForcePublishLogger
  attr_accessor :edition, :options

  def self.edition_published(edition, options)
    new(edition, options).save_remark!
  end

  def initialize(edition, options)
    @edition = edition
    @options = options
  end

  def save_remark!
    edition.editorial_remarks.create(body: reason, author: user)
  end

  def reason
    "Force published: #{options[:reason]}"
  end

  def user
    options[:user]
  end
end

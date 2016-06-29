class OffsiteLink < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  validates :title, :summary, :link_type, :url, presence: true, length: { maximum: 255 }
  validate :check_url_is_allowed
  validates :link_type, presence: true, inclusion: {in: %w{alert blog_post campaign careers service}}

  def check_url_is_allowed
    begin
      if (uri = Addressable::URI.parse(url))
        host = uri.host
      end

      unless url_is_gov_uk?(host) || url_is_gov_wales?(host)
        errors.add(:base, "Please enter a valid GOV.UK URL, such as https://www.gov.uk/jobsearch")
      end
    rescue URI::InvalidURIError
      errors.add(:base, "Please enter a valid URL, such as https://www.gov.uk/jobsearch")
    end
  end

  def humanized_link_type
    link_type.humanize
  end

  def to_s
    title
  end

private

  def url_is_gov_wales?(host)
    !!(host =~ /gov\.wales$/)
  end

  def url_is_gov_uk?(host)
    !!(host =~ /gov\.uk$/)
  end
end

class OffsiteLink < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  validates :title, :summary, :link_type, :url, presence: true
  validate :url_is_govuk
  validates :link_type, presence: true, inclusion: {in: %w{alert blog_post campaign careers service}}

  def url_is_govuk
    begin
      host = URI.parse(url).host
      split_host = host.split(".") if host
      if !host || split_host[split_host.length - 1] != "uk" || split_host[split_host.length - 2] != "gov"
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
end

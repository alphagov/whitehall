class OffsiteLink < ApplicationRecord
  module LinkTypes
    def self.all
      @types ||= %w(alert blog_post campaign careers manual nhs_content service)
    end

    def self.humanize(link_type)
      if link_type == 'nhs_content'
        'NHS content'
      else
        link_type.humanize
      end
    end

    def self.as_select_options
      all.map { |type| [humanize(type), type] }
    end
  end

  belongs_to :parent, polymorphic: true
  validates :title, :summary, :link_type, :url, presence: true, length: { maximum: 255 }
  validate :check_url_is_allowed
  validates :link_type, presence: true, inclusion: {in: LinkTypes.all}

  def check_url_is_allowed
    begin
      if (uri = Addressable::URI.parse(url))
        host = uri.host
      end

      unless government_or_whitelisted_url?(host)
        errors.add(:base, "Please enter a valid government URL, such as https://www.gov.uk/jobsearch")
      end
    rescue URI::InvalidURIError
      errors.add(:base, "Please enter a valid URL, such as https://www.gov.uk/jobsearch")
    end
  end

  def humanized_link_type
    LinkTypes.humanize(link_type)
  end

  def to_s
    title
  end

private

  def government_or_whitelisted_url?(host)
    url_is_gov_uk?(host) || url_is_gov_wales?(host) || url_is_gov_scot?(host) || url_is_whitelisted?(host)
  end

  def url_is_gov_scot?(host)
    !!(host =~ /gov\.scot$/)
  end

  def url_is_gov_wales?(host)
    !!(host =~ /gov\.wales$/)
  end

  def url_is_gov_uk?(host)
    !!(host =~ /gov\.uk$/)
  end

  def url_is_whitelisted?(host)
    whitelisted_hosts = [
      "flu-lab-net.eu",
      "tse-lab-net.eu",
      "beisgovuk.citizenspace.com",
      "nhs.uk",
    ]

    whitelisted_hosts.any? { |whitelisted_host| host =~ /(?:^|\.)#{whitelisted_host}$/}
  end
end

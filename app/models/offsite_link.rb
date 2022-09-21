class OffsiteLink < ApplicationRecord
  module LinkTypes
    def self.all
      @all ||= %w[
        alert
        blog_post
        campaign
        careers
        manual
        nhs_content
        service
        content_publisher_news_story
        content_publisher_press_release
      ]
    end

    def self.humanize(link_type)
      case link_type
      when "nhs_content"
        "NHS content"
      when "content_publisher_news_story"
        "News story (Content Publisher)"
      when "content_publisher_press_release"
        "Press release (Content Publisher)"
      else
        link_type.humanize
      end
    end

    def self.as_select_options
      all.map { |type| [humanize(type), type] }
    end

    def self.display_type(link_type)
      case link_type
      when "content_publisher_news_story"
        I18n.t("document.type.news_story", count: 1)
      when "content_publisher_press_release"
        I18n.t("document.type.press_release", count: 1)
      else
        I18n.t("document.type.#{link_type}", count: 1)
      end
    end
  end

  belongs_to :parent, polymorphic: true
  has_many :features, inverse_of: :offsite_link, dependent: :destroy

  validates :title, :summary, :link_type, :url, presence: true, length: { maximum: 255 }
  validate :check_url_is_allowed
  validates :link_type, presence: true, inclusion: { in: LinkTypes.all }

  def check_url_is_allowed
    if (uri = Addressable::URI.parse(url))
      host = uri.host
    end

    unless government_or_permitted_url?(host)
      errors.add(:base, "Please enter a valid government URL, such as https://www.gov.uk/jobsearch")
    end
  rescue URI::InvalidURIError
    errors.add(:base, "Please enter a valid URL, such as https://www.gov.uk/jobsearch")
  end

  def humanized_link_type
    LinkTypes.humanize(link_type)
  end

  def display_type
    LinkTypes.display_type(link_type)
  end

  def to_s
    title
  end

private

  def government_or_permitted_url?(host)
    url_is_gov_uk?(host) || url_is_gov_wales?(host) || url_is_gov_scot?(host) || url_is_permitted?(host)
  end

  def url_is_gov_scot?(host)
    host&.match?(/gov\.scot$/)
  end

  def url_is_gov_wales?(host)
    host&.match?(/gov\.wales$/)
  end

  def url_is_gov_uk?(host)
    host&.match?(/gov\.uk$/)
  end

  def url_is_permitted?(host)
    permitted_hosts = [
      "flu-lab-net.eu",
      "tse-lab-net.eu",
      "beisgovuk.citizenspace.com",
      "nhs.uk",
      "royal.uk",
    ]

    permitted_hosts.any? { |permitted_host| host =~ /(?:^|\.)#{permitted_host}$/ }
  end
end

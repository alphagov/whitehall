class AboutPage < ActiveRecord::Base
  include Searchable

  attr_accessible :body, :name, :summary, :read_more_link_text

  belongs_to :subject, polymorphic: true

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :read_more_link_text, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: (16.megabytes - 1) }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }

  validates_with SafeHtmlValidator

  searchable title: :name,
             link: :search_link,
             content: :indexable_content,
             description: :summary

  def search_link
    Whitehall.url_maker.topical_event_about_pages_path(subject.slug)
  end

  def indexable_content
    Govspeak::Document.new(body).to_text
  end
end

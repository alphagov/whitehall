class AboutPage < ActiveRecord::Base
  include Searchable

  attr_accessible :body, :name, :summary, :read_more_link_text

  belongs_to :subject, polymorphic: true

  validates :name, presence: true, uniqueness: true
  validates :read_more_link_text, presence: true
  validates :summary, presence: true
  validates :body, presence: true

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

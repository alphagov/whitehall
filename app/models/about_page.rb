class AboutPage < ActiveRecord::Base
  attr_accessible :body, :name, :summary, :read_more_link_text

  belongs_to :subject, polymorphic: true

  validates :name, presence: true, uniqueness: true
  validates :read_more_link_text, presence: true
  validates :summary, presence: true
  validates :body, presence: true
end

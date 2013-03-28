class HtmlVersion < ActiveRecord::Base
  belongs_to :edition

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :edition

  def should_generate_new_friendly_id?
    edition.nil? || !edition.document.published?
  end

  validates :title, :body, presence: true

  validates_with SafeHtmlValidator
end

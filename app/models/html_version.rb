class HtmlVersion < ActiveRecord::Base
  belongs_to :edition

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :edition

  validates :title, :body, presence: true

  validates_with SafeHtmlValidator
end

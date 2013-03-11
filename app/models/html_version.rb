class HtmlVersion < ActiveRecord::Base
  belongs_to :edition

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :edition

  validates_with SafeHtmlValidator
end

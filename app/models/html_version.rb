# == Schema Information
#
# Table name: html_versions
#
#  id         :integer          not null, primary key
#  edition_id :integer
#  title      :string(255)
#  body       :text(2147483647)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class HtmlVersion < ActiveRecord::Base
  belongs_to :edition

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :edition

  def should_generate_new_friendly_id?
    slug.nil? || edition.nil? || !edition.document.published?
  end

  validates :title, :body, presence: true

  validates_with SafeHtmlValidator
end

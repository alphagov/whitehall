class GovspeakContent < ActiveRecord::Base
  belongs_to :html_attachment, inverse_of: :govspeak_content

  validates :body, :html_attachment, presence: true
  validates_with SafeHtmlValidator
end

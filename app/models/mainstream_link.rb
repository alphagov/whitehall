class MainstreamLink < ActiveRecord::Base
  validates :url, :title, presence: true
  validates :url, format: URI::regexp(%w(http https))
end

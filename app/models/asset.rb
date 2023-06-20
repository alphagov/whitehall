class Asset < ApplicationRecord
  belongs_to :attachment_data

  validates :asset_manager_id, presence: true
  validates :attachment_data, presence: true
  validates :version, presence: true

  enum version: { original: "original".freeze, thumbnail: "thumbnail".freeze }
end

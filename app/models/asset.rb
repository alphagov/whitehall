class Asset < ApplicationRecord
  belongs_to :attachment_data

  validates :asset_manager_id, presence: true
  validates :attachment_data, presence: true
end

class FeaturedLink < ApplicationRecord
  extend ActiveSupport::Concern

  DEFAULT_SET_SIZE = 5

  belongs_to :linkable, polymorphic: true

  after_save :republish_organisation_to_publishing_api
  after_destroy :republish_organisation_to_publishing_api

  validates :url, :title, presence: true
  validates :url, uri: true

  def republish_organisation_to_publishing_api
    if linkable_type == "Organisation" && linkable.persisted?
      linkable.publish_to_publishing_api
    end
  end

  def self.only_the_initial_set
    limit(DEFAULT_SET_SIZE)
  end
end

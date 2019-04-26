class FeaturedLink < ApplicationRecord
  extend ActiveSupport::Concern

  DEFAULT_SET_SIZE = 5

  belongs_to :linkable, polymorphic: true

  after_commit :republish_organisation_to_publishing_api

  validates :url, :title, presence: true
  validates :url, uri: true
  validates_length_of :url, maximum: 255, message: "The URL can have maximum of 255 characters"

  def republish_organisation_to_publishing_api
    if linkable_type == "Organisation" && linkable.persisted?
      Whitehall::PublishingApi.republish_async(linkable)
    end
  end

  def self.only_the_initial_set
    limit(DEFAULT_SET_SIZE)
  end
end

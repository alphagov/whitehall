module Dependable
  extend ActiveSupport::Concern

  included do
    has_many :records_of_dependent_editions, class_name: "EditionDependency", as: :dependable, dependent: :destroy
    has_many :dependent_editions, through: :records_of_dependent_editions, source: :edition

    has_many :records_of_dependent_policy_groups, class_name: "PolicyGroupDependency", as: :dependable, dependent: :destroy
    has_many :dependent_policy_groups, through: :records_of_dependent_policy_groups, source: :policy_group
  end

  def republish_dependent_editions
    documents = dependent_editions.map(&:document)
    # We can't just republish the published editions because that might trash
    # any draft editions stored in publishing-api. Therefore we need to
    # republish the published and draft editions in the correct order, via
    # republish_document_async.
    documents.each { |e| Whitehall::PublishingApi.republish_document_async(e) }
  end

  def republish_dependent_policy_groups
    dependent_policy_groups.each { |policy_group| Whitehall::PublishingApi.republish_async(policy_group) }
  end
end

module Dependable
  extend ActiveSupport::Concern

  included do
    has_many :dependency_records, class_name: 'EditionDependency', as: :dependable, dependent: :destroy
    has_many :dependent_editions, through: :dependency_records, source: :edition
  end

  def republish_dependent_editions
    dependent_editions.each { |e| Whitehall::PublishingApi.republish(e) }
  end

  def destroy_dependency_records
    # once a draft edition gets published, dependent editions are no longer
    # affected by future changes to that edition, so no longer remain dependent.
    dependency_records.destroy_all
  end

end

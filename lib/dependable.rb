module Dependable
  extend ActiveSupport::Concern

  included do
    has_many :records_of_dependent_editions, class_name: 'EditionDependency', as: :dependable, dependent: :destroy
    has_many :dependent_editions, through: :records_of_dependent_editions, source: :edition
  end

  def republish_dependent_editions
    dependent_editions.each { |e| Whitehall::PublishingApi.republish(e) }
  end

  def destroy_records_of_dependent_editions
    # once a draft edition gets published, dependent editions are no longer
    # affected by future changes to that edition, so no longer remain dependent.
    records_of_dependent_editions.destroy_all
  end

end

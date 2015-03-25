module Dependable
  extend ActiveSupport::Concern

  included do
    has_many :records_of_dependent_editions, class_name: 'EditionDependency', as: :dependable, dependent: :destroy
    has_many :dependent_editions, through: :records_of_dependent_editions, source: :edition
  end

  def republish_dependent_editions
    dependent_editions.each { |e| Whitehall::PublishingApi.republish_async(e) }
  end
end

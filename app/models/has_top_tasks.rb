module HasTopTasks
  extend ActiveSupport::Concern

  included do
    has_many :top_tasks, as: :linkable, dependent: :destroy, order: :created_at
    accepts_nested_attributes_for :top_tasks, reject_if: -> attributes { attributes['url'].blank? }, allow_destroy: true
  end
end

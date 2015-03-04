class EditionDependency < ActiveRecord::Base
  belongs_to :dependant, class_name: 'Edition'
  belongs_to :dependable, polymorphic: true

  scope :contacts, -> { where(dependable_type: 'Contact') }
end

class EditionDependency < ApplicationRecord
  belongs_to :edition
  belongs_to :dependable, polymorphic: true
end

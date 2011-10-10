class DocumentRole < ActiveRecord::Base
  belongs_to :document
  belongs_to :role
end
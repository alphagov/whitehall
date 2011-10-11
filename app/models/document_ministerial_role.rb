class DocumentMinisterialRole < ActiveRecord::Base
  belongs_to :document
  belongs_to :ministerial_role
end
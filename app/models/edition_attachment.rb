class EditionAttachment < ActiveRecord::Base
  belongs_to :attachment, dependent: :destroy
  belongs_to :edition

  accepts_nested_attributes_for :attachment

end

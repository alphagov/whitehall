class EditionAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :edition

  accepts_nested_attributes_for :attachment

end

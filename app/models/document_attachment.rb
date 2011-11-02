class DocumentAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :document
end

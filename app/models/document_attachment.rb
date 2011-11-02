class DocumentAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :document

  after_destroy :inform_attachment

  private

  def inform_attachment
    attachment.destroy_if_unassociated
  end
end

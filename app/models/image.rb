class Image < ActiveRecord::Base
  belongs_to :image_data
  belongs_to :document

  validates :alt_text, presence: true

  after_destroy :destroy_image_data_if_required

  accepts_nested_attributes_for :image_data, reject_if: :all_blank

  private

  def destroy_image_data_if_required
    unless Image.where(image_data_id: image_data.id).any?
      image_data.destroy
    end
  end
end
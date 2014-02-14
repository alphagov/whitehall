class Image < ActiveRecord::Base
  belongs_to :image_data
  belongs_to :edition

  validates :alt_text, presence: true, unless: :skip_main_validation?
  validates :image_data, presence: { message: 'must be present' }

  after_destroy :destroy_image_data_if_required

  accepts_nested_attributes_for :image_data

  default_scope -> { order(:id) }

  def url(*args)
    image_data.file_url(*args)
  end

  private

  def destroy_image_data_if_required
    if image_data && Image.where(image_data_id: image_data.id).empty?
      image_data.destroy
    end
  end

  def skip_main_validation?
    edition && edition.skip_main_validation?
  end
end

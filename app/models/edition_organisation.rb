# == Schema Information
#
# Table name: edition_organisations
#
#  id                                 :integer          not null, primary key
#  edition_id                         :integer
#  organisation_id                    :integer
#  created_at                         :datetime
#  updated_at                         :datetime
#  featured                           :boolean          default(FALSE)
#  ordering                           :integer
#  edition_organisation_image_data_id :integer
#  alt_text                           :string(255)
#  lead                               :boolean          default(FALSE), not null
#  lead_ordering                      :integer
#

class EditionOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :organisation
  belongs_to :image, class_name: 'EditionOrganisationImageData', foreign_key: :edition_organisation_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :edition, :organisation, presence: true
  validates :image, :alt_text, presence: true, if: :featured?
end

# == Schema Information
#
# Table name: organisation_types
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  analytics_prefix :string(255)
#

class OrganisationType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  LISTING_ORDER = [
    "Executive office",
    "Ministerial department",
    "Non-ministerial department",
    "Executive agency",
    "Executive non-departmental public body",
    "Advisory non-departmental public body",
    "Tribunal non-departmental public body",
    "Public corporation",
    "Independent monitoring body",
    "Ad-hoc advisory group",
    "Sub-organisation",
    "Other"
  ]
  BOTTOM_OF_LISTING_ORDER = 99

  def self.in_listing_order
    all.sort_by { |ot| ot.listing_order }
  end

  def self.unlistable
    sub_organisation
  end

  def self.sub_organisation
    where(name: "Sub-organisation")
  end

  def self.executive_office
    where(name: "Executive office").first
  end

  def self.agency_or_public_body
    where(arel_table[:name].not_eq("Sub-organisation"))
  end

  def self.ministerial_department
    where(name: "Ministerial department").first
  end

  def listing_order
    LISTING_ORDER.index(name) || BOTTOM_OF_LISTING_ORDER
  end

  def ministerial_department?
    name == "Ministerial department"
  end

  def department?
    name =~ /\bdepartment\b/i
  end

  def self.departmental_types
    all.select { |t| t.department? }
  end

  def sub_organisation?
    name == "Sub-organisation"
  end

  def executive_office?
    name == 'Executive office'
  end
end

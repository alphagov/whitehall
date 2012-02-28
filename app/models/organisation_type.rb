class OrganisationType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  LISTING_ORDER = [
    "Ministerial department",
    "Non-ministerial department",
    "Executive agency",
    "Executive non-departmental public body",
    "Advisory non-departmental public body",
    "Tribunal non-departmental public body",
    "Public corporation",
    "Independent monitoring body",
    "Ad-hoc advisory group",
    "Other"
  ]

  def self.in_listing_order
    all.sort_by { |ot| ot.listing_order }
  end

  def listing_order
    LISTING_ORDER.index(name)
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
end

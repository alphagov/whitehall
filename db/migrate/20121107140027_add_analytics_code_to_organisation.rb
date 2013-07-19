class AddAnalyticsCodeToOrganisation < ActiveRecord::Migration
  TYPES_TO_PREFIX = {
    "Ministerial department" => "D",
    "Non-ministerial department" => "D",
    "Executive agency" => "EA",
    "Executive non-departmental public body" => "PB",
    "Advisory non-departmental public body" => "PB",
    "Tribunal non-departmental public body" => "PB",
    "Public corporation" => "PC",
    "Independent monitoring body" => "IM",
    "Ad-hoc advisory group" => "AG",
    "Other" => "OT"
  }

  class OrganisationType < ActiveRecord::Base
  end

  class Organisation < ActiveRecord::Base
    belongs_to :organisation_type
  end

  def up
    add_column :organisations, :analytics_identifier, :string
    add_column :organisation_types, :analytics_prefix, :string


    TYPES_TO_PREFIX.each do |name, prefix|
      if (organisation = OrganisationType.find_by_name(name))
        organisation.update_column(:analytics_prefix, prefix)
      end
    end

    Organisation.find_each do |o|
      o.update_column(:analytics_identifier, o.organisation_type.analytics_prefix + o.id.to_s)
    end
  end

  def down
    remove_column :organisations, :analytics_identifier
    remove_column :organisation_types, :analytics_prefix
  end
end

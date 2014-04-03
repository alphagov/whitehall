class LandRegistrySlugChange < ActiveRecord::Migration
  def up
    change_org_slug('hm-land-registry', 'land-registry')
  end

  def down
    change_org_slug('land-registry', 'hm-land-registry')
  end

  private

  def change_org_slug(old_slug, new_slug)
    Organisation.transaction do
      if o = Organisation.where(:slug => old_slug).first
        puts "Changing organisation slug #{old_slug} -> #{new_slug}"
        o.update_column(:slug, new_slug)
        User.where(:organisation_slug => old_slug).each do |user|
          user.update_column(:organisation_slug, new_slug)
        end
      end
    end
  end
end

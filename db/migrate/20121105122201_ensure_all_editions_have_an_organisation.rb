class EnsureAllEditionsHaveAnOrganisation < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base; end

  def up
    default_organisation = Organisation.order(:name).first
    execute "
    insert into edition_organisations (edition_id, organisation_id, updated_at)
      select editions.id, #{default_organisation.id}, now() from editions where not exists (
        select * from edition_organisations eocheck where eocheck.edition_id = editions.id
        );
    "
  end

  def down
  end
end

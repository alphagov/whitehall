class BackfillAccessLimitingOrganisations < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<~SQL
        UPDATE editions
        SET access_limiting = 'none'
        WHERE access_limiting = 'organisations'
          AND (
            state NOT IN ('draft', 'submitted', 'rejected', 'scheduled')
            OR type = 'CorporateInformationPage'
            OR NOT EXISTS (
              SELECT 1 FROM edition_organisations eo
              WHERE eo.edition_id = editions.id
                AND eo.organisation_id IS NOT NULL
            )
          )
      SQL

      execute <<~SQL
        INSERT INTO access_limiting_organisations (edition_id, organisation_id, created_at, updated_at)
        SELECT eo.edition_id, eo.organisation_id, NOW(), NOW()
        FROM edition_organisations eo
        INNER JOIN editions e ON e.id = eo.edition_id
        WHERE e.access_limiting = 'organisations'
          AND e.state IN ('draft', 'submitted', 'rejected', 'scheduled')
          AND e.type <> 'CorporateInformationPage'
          AND eo.organisation_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 FROM access_limiting_organisations alo
            WHERE alo.edition_id = eo.edition_id
              AND alo.organisation_id = eo.organisation_id
          )
      SQL
    end
  end

  def down; end
end

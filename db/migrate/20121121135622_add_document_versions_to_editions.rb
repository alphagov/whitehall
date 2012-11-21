class AddDocumentVersionsToEditions < ActiveRecord::Migration
  def up
    add_column :editions, :published_major_version, :integer
    add_column :editions, :published_minor_version, :integer

    # Create a temporary table to work out the first major editions of a document, which is the first created edition
    execute %{
      CREATE TEMPORARY TABLE first_editions
      SELECT editions.id as edition_id
      FROM editions
      WHERE NOT EXISTS (
        SELECT 1 FROM editions e2
        WHERE e2.created_at < editions.created_at
        AND e2.document_id = editions.document_id
      );
    }

    # Add the major editions back into the editions table
    execute %{
      UPDATE editions
      JOIN first_editions ON (editions.id = edition_id)
      SET editions.minor_change = 0;
    }

    # Calculate the major version numbers for documents
    execute %{
      CREATE TEMPORARY TABLE edition_published_major_versions
      SELECT
        editions.id as edition_id,
        (SELECT count(*)
          FROM editions e2 where e2.created_at <= editions.created_at
          AND e2.minor_change = 0
          AND e2.document_id = editions.document_id
        ) as published_major_version
      FROM editions
      WHERE state IN ('published', 'archived', 'deleted');
    }

    # Adding an index speeds up the next insertions by 1000x
    execute %{
      CREATE INDEX edition_published_major_versions_edition_id ON edition_published_major_versions (edition_id);
    }

    # Add the major versions back into the editions table
    execute %{
      UPDATE editions
      SET published_major_version = (
        SELECT published_major_version
        FROM edition_published_major_versions
        WHERE edition_id = editions.id
      );
    }

    # Do the same for minor editions
    execute %{
      CREATE TEMPORARY TABLE edition_published_minor_versions
      SELECT id as edition_id, (
        SELECT count(*)
        FROM editions e2
        WHERE
        e2.created_at < editions.created_at
        AND e2.published_major_version = editions.published_major_version
        AND e2.document_id = editions.document_id
      ) as published_minor_version
      from editions
      WHERE state IN ('published', 'archived', 'deleted');
    }

    execute %{
      CREATE INDEX edition_published_minor_versions_edition_id ON edition_published_minor_versions (edition_id);
    }

    execute %{
      UPDATE editions
      SET published_minor_version = (
        SELECT published_minor_version
        FROM edition_published_minor_versions
        WHERE edition_id = editions.id
      );
    }

    # Remove the temporary tables.
    execute %{
      DROP TABLE edition_published_major_versions;
    }

    execute %{
      DROP TABLE edition_published_minor_versions;
    }

  end

  def down
    remove_column :editions, :published_major_version
    remove_column :editions, :published_minor_version
  end
end

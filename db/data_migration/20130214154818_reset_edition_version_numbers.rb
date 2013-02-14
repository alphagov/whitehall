# Reset all editions major and minor version numbers
# based on db/migrate/20121121135622_add_document_versions_to_editions.rb

# Calculate the major version numbers for documents
ActiveRecord::Base.connection.execute %{
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
ActiveRecord::Base.connection.execute %{
  CREATE INDEX edition_published_major_versions_edition_id ON edition_published_major_versions (edition_id);
}

# Add the major versions back into the editions table
ActiveRecord::Base.connection.execute %{
  UPDATE editions
  SET published_major_version = (
    SELECT published_major_version
    FROM edition_published_major_versions
    WHERE edition_id = editions.id
  );
}

# Do the same for minor editions
ActiveRecord::Base.connection.execute %{
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

ActiveRecord::Base.connection.execute %{
  CREATE INDEX edition_published_minor_versions_edition_id ON edition_published_minor_versions (edition_id);
}

ActiveRecord::Base.connection.execute %{
  UPDATE editions
  SET published_minor_version = (
    SELECT published_minor_version
    FROM edition_published_minor_versions
    WHERE edition_id = editions.id
  );
}

# Remove the temporary tables.
ActiveRecord::Base.connection.execute %{
  DROP TABLE edition_published_major_versions;
}

ActiveRecord::Base.connection.execute %{
  DROP TABLE edition_published_minor_versions;
}

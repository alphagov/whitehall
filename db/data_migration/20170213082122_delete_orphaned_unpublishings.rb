orphaned_unpublishings = Unpublishing.find_by_sql <<-SQL
                            SELECT *
                            FROM unpublishings
                            WHERE edition_id NOT IN (
                              SELECT id FROM editions
                            )
SQL

Unpublishing.delete(orphaned_unpublishings.map(&:id))

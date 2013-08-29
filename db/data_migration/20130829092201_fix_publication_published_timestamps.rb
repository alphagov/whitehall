Publication.where(first_published_at: nil).update_all('first_published_at = publication_date')

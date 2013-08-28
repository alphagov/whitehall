
# We have removed the lagacy PublicationType::Consultation, but there are still half
# a dozen archived editions with this type. We force their type to Guidance, which
# is what the type of their latest editions is.
Publication.where(publication_type_id: 16).update_all('publication_type_id = 3')

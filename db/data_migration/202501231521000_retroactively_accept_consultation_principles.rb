# When the validation requiring publishers to confirm that they have considered the consultation principles was introduced,
# we did not backdate this to existing consultations. This means that some consultations cannot be withdrawn, unwithdrawn
# or unpublished because they are not technically valid, despite being public on GOV.UK. This data migration retroactively
# confirms that all post-publication consultations have considered the consultation principles.

Consultation.where(state: Edition::POST_PUBLICATION_STATES).update_all(read_consultation_principles: true)

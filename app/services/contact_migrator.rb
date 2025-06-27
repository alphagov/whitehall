# Temporary class used to migrate non-existent contact IDs to existing ones.
# It will be deleted after use. It should be safe to delete at that point,
# even considering local development, because nobody needs to run `rake
# db:data:migrate` on an empty/seeded database, and if they've got a fresh
# copy of the production data then they'll also have the production records
# of `DataMigration` showing that the migration has been running (and therefore
# automatically skip over it).
#
# Trello: https://trello.com/c/b1CjWMUP

class ContactMigrator
  def self.call(...)
    new.call(...)
  end

  def call(edition_id: nil, html_attachment_id: nil, contact_mapping: nil)
    raise ArgumentError, "Bad parameters" unless contact_mapping &&
      ((edition_id && !html_attachment_id) || (!edition_id && html_attachment_id))

    @contact_mapping = contact_mapping
    @old_contact_ids = contact_mapping.map { |contact| contact[:old_contact_id] }

    if edition_id
      migrate_contacts_on_edition(Edition.find(edition_id))
    else
      migrate_contacts_on_html_attachment(HtmlAttachment.find(html_attachment_id))
    end
  end

private

  def migrate_contacts_on_edition(edition)
    updated_body = replace_contact_ids(edition.body)
    return if updated_body == edition.body

    should_publish_the_updated_draft = false
    if edition.state == "published"
      edition = create_new_draft(edition)
      should_publish_the_updated_draft = true
    end
    if edition.editable?
      edition.update!(minor_change: true, body: updated_body)
      publish_edition(edition) if should_publish_the_updated_draft
    else
      Rails.logger.debug "Unable to process edition #{edition.id} due to its state (#{edition.state})"
    end
  end

  def migrate_contacts_on_html_attachment(_html_attachment)
    # TODO: implement!
  end

  def create_new_draft(published_edition)
    AuditTrail.acting_as(robot_user) do
      published_edition.create_draft(robot_user)
    end
  end

  def robot_user
    User.find_by(name: "Scheduled Publishing Robot", uid: nil)
  end

  def replace_contact_ids(body)
    updated_body = body.dup
    referenced_ids = Govspeak::ContactsExtractor.new(body).extracted_contact_ids
    ids_to_replace = referenced_ids & @old_contact_ids
    ids_to_replace.each do |old_id|
      new_id = @contact_mapping.find { |contact| contact[:old_contact_id] == old_id }[:new_contact_id]
      updated_body.gsub!(/\[Contact:#{old_id}\]/, "[Contact:#{new_id}]")
    end
    updated_body
  end

  def publish_edition(draft_edition)
    edition_publisher = Whitehall.edition_services.force_publisher(
      draft_edition,
      user: robot_user,
      remark: "Automatically patched old (non existent) contact ID for new equivalent",
    )
    edition_publisher.perform!
  end
end

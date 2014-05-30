module DataHygiene
  class ConvertCorporateInformationPages

    def initialize(logger = nil)
      @gds_ig_team_user = User.find_by_name!('GDS Inside Government Team')
      @logger = logger
    end

    def convert(old_cip)
      org = old_cip.organisation
      log "Migrating #{org.name}: #{old_cip.slug} (#{old_cip.id})"
      doc = Document.create!(document_type: 'CorporateInformationPage',
                             created_at: old_cip.created_at,
                             updated_at: old_cip.updated_at)
      new_cip = org.build_corporate_information_page(
        created_at: old_cip.created_at,
        updated_at: old_cip.updated_at,
        lock_version: old_cip.lock_version,
        document_id: doc.id,
        creator: @gds_ig_team_user,
        summary: old_cip.summary,
        body: old_cip.body,
        corporate_information_page_type_id: old_cip.type_id,
        major_change_published_at: old_cip.updated_at,
        state: 'published')
      new_cip.save!
      old_cip.translations.each do |old_trans|
        unless old_trans.locale == :en
          log "\tMigrating :#{old_trans.locale} translation"
          new_cip.translations.create!(
            locale: old_trans.locale,
            summary: old_trans.summary,
            body: old_trans.body,
            title: ''
          )
        end
      end
      old_cip.attachments.each do |old_att|
        log "\tMigrating attachment: #{old_att.title} (#{old_att.id})"
        # Create new Attachments, but keep existing attachment_data instances.
        # Can't set attachment_type directly, so use the class of the
        # existing instance to create the new one.
        old_att.class.create!(
          created_at: old_att.created_at,
          updated_at: old_att.updated_at,
          title: old_att.title,
          accessible: old_att.accessible,
          isbn: old_att.isbn,
          unique_reference: old_att.unique_reference,
          command_paper_number: old_att.command_paper_number,
          order_url: old_att.order_url,
          price_in_pence: old_att.price_in_pence,
          attachment_data_id: old_att.attachment_data_id,
          ordering: old_att.ordering,
          hoc_paper_number: old_att.hoc_paper_number,
          parliamentary_session: old_att.parliamentary_session,
          unnumbered_command_paper: old_att.unnumbered_command_paper,
          unnumbered_hoc_paper: old_att.unnumbered_hoc_paper,
          slug: old_att.slug,
          body: old_att.body,
          manually_numbered_headings: old_att.manually_numbered_headings,
          locale: old_att.locale,
          attachable_type: "Edition",
          attachable_id: new_cip.id,
        )
      end
      # The unique identifier in the search index is the page URL, which has
      # not changed in this migration, so we can just trigger an update.
      new_cip.update_in_search_index
    end

    def log(msg)
      @logger.info(msg) if @logger
    end
  end
end

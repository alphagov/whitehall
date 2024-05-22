# rubocop:disable Rails/SkipsModelValidations

class MigrateWorldwideOrganisationsToEditions < ActiveRecord::Migration[7.1]
  include Admin::EditionRoutesHelper
  include Rails.application.routes.url_helpers

  def up
    ## Some actions requre an actor, so use the migration author
    actor = User.find_by(email: "bruce.bolt@digital.cabinet-office.gov.uk")

    ## Disable version history callbacks, as we don't want an audit trail item for the create/updates in this migration
    Edition.skip_callback(:create, :after, :record_create)
    Edition.skip_callback(:update, :before, :record_update)

    ## Disable Publishing API callbacks, as we don't want anything published on update until the migration has been completed
    Contact.skip_callback(:commit, :after, :publish_to_publishing_api)
    Contact.skip_callback(:commit, :after, :republish_embassies_index_page_to_publishing_api)
    Contact.skip_callback(:commit, :after, :republish_worldwide_office_to_publishing_api)
    WorldwideOffice.skip_callback(:commit, :after, :publish_to_publishing_api)
    WorldwideOffice.skip_callback(:commit, :after, :republish_embassies_index_page_to_publishing_api)
    WorldwideOrganisation.skip_callback(:commit, :after, :publish_to_publishing_api)
    WorldwideOrganisation.skip_callback(:commit, :after, :republish_embassies_index_page_to_publishing_api)
    WorldwideOrganisation.skip_callback(:commit, :after, :republish_worldwide_offices)
    WorldwideOrganisationPage.skip_callback(:commit, :after, :republish_worldwide_organisation_draft)

    ## Disable Whitehall's attempts at changing the slug, e.g. dropping `the-` from the beginning
    Edition.skip_callback(:validation, :before, :update_document_slug)

    ## These counts will be used for the logging output
    total = WorldwideOrganisation.all.count
    Rails.logger.info "Total organisations to migrate #{total}"
    completed = 0
    failed = 0

    ## Wrapping the entire migration in a transaction, so it can be rolled back if the integrity check fails
    ActiveRecord::Base.transaction do
      WorldwideOrganisation.find_each do |worldwide_organisation|
        Rails.logger.info "Worldwide Organisation: #{worldwide_organisation.slug}"

        ## Worldwide Organisation Document
        editionable_worldwide_organisation_document = Document.create!(
          content_id: worldwide_organisation.content_id,
          created_at: worldwide_organisation.created_at,
          document_type: "EditionableWorldwideOrganisation",
          slug: worldwide_organisation.slug,
        )

        ## The 'About us' page is being merged into the main document
        about_us_page = worldwide_organisation.corporate_information_pages.find_by(state: "published", corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id)

        ## Remove legacy attachment syntax which relies on the ordering of attachments in the database
        updated_body = convert_legacy_attachment_syntax(worldwide_organisation.body, about_us_page.attachments) if about_us_page
        updated_summary = convert_legacy_attachment_syntax(worldwide_organisation.summary, about_us_page.attachments) if about_us_page

        ## Worldwide Organisation Edition
        editionable_worldwide_organisation_published_edition = EditionableWorldwideOrganisation.new(
          analytics_identifier: worldwide_organisation.analytics_identifier,
          body: updated_body,
          created_at: worldwide_organisation.created_at,
          creator: actor,
          document: editionable_worldwide_organisation_document,
          lead_organisations: worldwide_organisation.sponsoring_organisations,
          locale: "en",
          logo_formatted_name: worldwide_organisation.logo_formatted_name,
          previously_published: false,
          roles: worldwide_organisation.roles,
          summary: updated_summary,
          title: worldwide_organisation.name,
          world_locations: worldwide_organisation.world_locations,
        )

        editionable_worldwide_organisation_published_edition.save!(validate: false, touch: false)

        ## Attach attachments from the 'About us' page to the new edition
        if about_us_page
          about_us_page.attachments.map do |attachment|
            editionable_worldwide_organisation_published_edition.attachments.create!(attachment.attributes.except("id", "attachable_id", "attachable_type"))
          end
        end

        ## Translations of the 'About us' page
        worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
          I18n.with_locale(locale) do
            editionable_worldwide_organisation_published_edition.assign_attributes(
              body: worldwide_organisation.body,
              summary: worldwide_organisation.summary,
              title: worldwide_organisation.name,
            )

            editionable_worldwide_organisation_published_edition.save!(validate: false, touch: false)
          end
        end

        ## Default news image
        if worldwide_organisation.default_news_image.present?
          editionable_worldwide_organisation_published_edition.create_default_news_image(worldwide_organisation.default_news_image.attributes.except("id", "featured_imageable_id", "featured_imageable_type"))

          worldwide_organisation.default_news_image.assets.each do |asset|
            editionable_worldwide_organisation_published_edition.default_news_image.assets << asset.dup
          end
        end

        ## Social media links
        worldwide_organisation.social_media_accounts.each do |social_media_account|
          new_social_media_account = editionable_worldwide_organisation_published_edition.social_media_accounts.create!(social_media_account.attributes.except("id", "socialable_id", "socialable_type"))

          worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
            I18n.with_locale(locale) do
              new_social_media_account.update!(social_media_account.attributes.except("id", "socialable_id", "socialable_type"))
            end
          end
        end

        ## Offices
        home_page_offices = [worldwide_organisation.main_office, worldwide_organisation.home_page_offices].compact.flatten
        other_offices = worldwide_organisation.offices - home_page_offices
        all_offices_in_order = home_page_offices + other_offices

        all_offices_in_order.each do |office|
          new_office = editionable_worldwide_organisation_published_edition.offices.new(office.attributes.except("id", "worldwide_organisation_id"))
          new_office.contact = Contact.create(office.contact.attributes.except("id", "contactable_id", "contactable_type"))
          new_office.save!

          office.contact.contact_numbers.each do |contact_number|
            new_contact_number = new_office.contact.contact_numbers.create!(contact_number.attributes.except("id", "contact_id"))

            contact_number.translations.each do |translation|
              I18n.with_locale(translation.locale) do
                new_contact_number.update!(translation.attributes.except("id", "contact_number_id"))
              end
            end

            new_contact_number.update!(
              updated_at: contact_number.updated_at,
            )
          end

          office.services.each do |service|
            new_office.services << service
          end

          if worldwide_organisation.office_shown_on_home_page?(office)
            editionable_worldwide_organisation_published_edition.add_office_to_home_page!(new_office)
          end

          worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
            next unless office.contact.translations.pluck(:locale).include?(locale.to_s)

            I18n.with_locale(locale) do
              new_office.update!(office.attributes.except("id", "edition_id", "worldwide_organisation_id"))
              new_office.contact.attributes = office.contact.attributes.except("id", "contactable_id", "contactable_type")
              new_office.contact.save!(validate: false) ## Some offices appear to have no country in their translation (perhaps they were added before the validation was implemented), so don't do this validation now
            end
          end

          new_office.contact.translations.each do |translation|
            I18n.with_locale(translation.locale) do
              translation.update!(
                updated_at: office.contact.translation.updated_at,
              )
            end
          end
        end

        ## History for the published edition
        worldwide_organisation.versions.sort_by(&:created_at).each do |version|
          editionable_worldwide_organisation_published_edition.versions.create(version.attributes.except("id", "item_id", "item_type", "state").merge(state: "draft"))
        end

        ## Published Corporate Information Pages
        published_corporate_information_pages = worldwide_organisation.corporate_information_pages.where(state: "published")
        published_corporate_information_pages.find_each do |cip|
          ## About Us pages have already been migrated into the main EditionableWorldwideOrganisation edition's body and summary
          next if cip.corporate_information_page_type_id == CorporateInformationPageType::AboutUs.id

          ## Remove legacy attachment syntax which relies on the ordering of attachments in the database
          updated_body = convert_legacy_attachment_syntax(cip.body, cip.attachments)
          updated_summary = convert_legacy_attachment_syntax(cip.summary, cip.attachments)

          ## Create a new WorldwideOrganisationPage for each Corporate Information Page
          new_page = editionable_worldwide_organisation_published_edition.pages.new(
            body: updated_body,
            content_id: cip.content_id,
            corporate_information_page_type: cip.corporate_information_page_type,
            created_at: cip.created_at,
            edition: editionable_worldwide_organisation_published_edition,
            summary: updated_summary,
          )

          new_page.save!(validate: false, touch: false)

          ## Attachments for the Corporate Information Page
          cip.attachments.map do |attachment|
            new_page.attachments.create!(attachment.attributes.except("id", "attachable_id", "attachable_type"))
          end

          ## Translations for the Corporate Information Page
          worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
            next unless cip.translations.pluck(:locale).include?(locale.to_s)

            I18n.with_locale(locale) do
              new_page.assign_attributes(
                body: cip.body,
                summary: cip.summary,
              )

              new_page.save!(validate: false, touch: false)
            end
          end

          ## Editorial remark to log the migration
          body = "Migrated published corporate information page <a href=\"#{admin_edition_path(cip.document.live_edition)}\" class=\"govuk-link\">'#{cip.title}'</a>"
          remark = EditorialRemark.new(edition: editionable_worldwide_organisation_published_edition, body:)
          remark.save!(validate: false)

          ## Backdating the updated_at timestamp needs to be done last, as updating the translations means the date changes
          new_page.update_columns(
            updated_at: cip.public_timestamp || cip.updated_at,
          )
        end

        ## Reassociate editions (e.g. world news stories) with the new organisation
        EditionWorldwideOrganisation.where(worldwide_organisation:).find_each do |edition_worldwide_organisation|
          EditionEditionableWorldwideOrganisation.create!(
            edition: edition_worldwide_organisation.edition,
            document: editionable_worldwide_organisation_document,
          )
        end

        ## Updating the updated at time needs to be the very last thing, else the `update` calls above will change it
        ## We also cannot update a published edition, so need to set this at the very end
        ## Using `update_columns` to skip validations as some legacy worldwide organisations do not have a body or world locations
        editionable_worldwide_organisation_published_edition.update_columns(
          major_change_published_at: worldwide_organisation.updated_at,
          state: "published",
          updated_at: worldwide_organisation.updated_at,
        )

        ## Draft Corporate Information Pages (CIPs)
        draft_cips = worldwide_organisation.corporate_information_pages.where(state: "draft")
        if draft_cips.any?
          Rails.logger.info "Organisation has draft CIPs"

          ## Create a draft edition (the `create_draft` method copies all the associated stuff to the new edition for us)
          editionable_worldwide_organisation_draft_edition = editionable_worldwide_organisation_published_edition.create_draft(actor)

          ## Draft 'About us' page
          if (draft_about_us_page = draft_cips.find_by(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id))
            updated_body = if draft_about_us_page.body
                             convert_legacy_attachment_syntax(draft_about_us_page.body, draft_about_us_page.attachments)
                           end

            updated_summary = if draft_about_us_page.summary
                                convert_legacy_attachment_syntax(draft_about_us_page.summary, draft_about_us_page.attachments)
                              end

            ## Using `update_attribute` to skip validations as some legacy worldwide organisations do not have a body or world locations
            editionable_worldwide_organisation_draft_edition.update_attribute(:body, updated_body)
            editionable_worldwide_organisation_draft_edition.update_attribute(:summary, updated_summary)

            ## Attachments from the draft 'About us' page
            draft_about_us_page.attachments.map do |attachment|
              new_attachment = editionable_worldwide_organisation_draft_edition.attachments.find_or_create_by!(attachment_data_id: attachment.attachment_data_id)
              new_attachment.update!(attachment.attributes.except("id", "attachable_id", "attachable_type"))
            end

            ## Translations from the draft 'About us' page
            worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
              I18n.with_locale(locale) do
                editionable_worldwide_organisation_draft_edition.assign_attributes(
                  body: draft_about_us_page.body,
                  summary: draft_about_us_page.summary,
                )

                editionable_worldwide_organisation_draft_edition.save!(validate: false, touch: false)
              end
            end
          end

          ## Draft non-about us Corporate Information Pages (CIPs)
          if (other_draft_pages = draft_cips.where.not(corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id))
            other_draft_pages.each do |draft_page|
              updated_body = if draft_page.body
                               convert_legacy_attachment_syntax(draft_page.body, draft_page.attachments)
                             end

              updated_summary = if draft_page.summary
                                  convert_legacy_attachment_syntax(draft_page.summary, draft_page.attachments)
                                end

              ## Update the existing page or create a new one (e.g. if the CIP has never been published before)
              new_page = editionable_worldwide_organisation_draft_edition.pages.find_or_initialize_by(corporate_information_page_type_id: draft_page.corporate_information_page_type_id)
              new_page.assign_attributes(
                body: updated_body,
                content_id: draft_page.content_id,
                corporate_information_page_type: draft_page.corporate_information_page_type,
                created_at: draft_page.created_at,
                summary: updated_summary,
              )
              new_page.save!(validate: false, touch: false)

              ## Attachments for the draft Corporate Information Page
              draft_page.attachments.map do |attachment|
                new_attachment = new_page.attachments.find_or_initialize_by(attachment_data_id: attachment.attachment_data_id)
                new_attachment.update!(attachment.attributes.except("id", "attachable_id", "attachable_type"))
                new_attachment.save!
              end

              ## Translations for the draft Corporate Information Page
              worldwide_organisation.non_english_translated_locales.map(&:code).each do |locale|
                I18n.with_locale(locale) do
                  new_page.assign_attributes(
                    body: draft_page.body,
                    summary: draft_page.summary,
                  )
                  new_page.save!(validate: false, touch: false)
                end
              end

              ## Editorial remark to log the migration
              body = "Migrated draft corporate information page <a href=\"#{admin_edition_path(draft_page.document.latest_edition)}\" class=\"govuk-link\">'#{draft_page.title}'</a>"
              remark = EditorialRemark.new(edition: editionable_worldwide_organisation_draft_edition, body:)
              remark.save!(validate: false)

              ## Backdating the updated_at timestamp needs to be done last, as updating the translations means the date changes
              new_page.update_columns(
                updated_at: draft_page.public_timestamp || draft_page.updated_at,
              )
            end
          end

          ## History for the draft edition
          all_version_history = worldwide_organisation.corporate_information_pages.where(state: "draft").map(&:versions).flatten
          create_exists = false
          all_version_history.sort_by(&:created_at).each do |version|
            if create_exists && version.event == "create"
              editionable_worldwide_organisation_draft_edition.versions.create!(version.attributes.except("id", "item_id", "item_type", "state", "event").merge(event: "update", state: "draft"))
            else
              editionable_worldwide_organisation_draft_edition.versions.create!(version.attributes.except("id", "item_id", "item_type", "state").merge(state: "draft"))
            end

            ## We only want to capture the first create event as a "create", every other draft CIP created should be a "update"
            ## Otherwise we get "Document created" appear within the history of the draft edition
            create_exists if version.event == "create"
          end

          ## Override the draft edition's timestamps to reflect the draft CIPs we have used to create it
          # Using `update_columns` to skip validations as some legacy worldwide organisations do not have a body or world locations
          editionable_worldwide_organisation_draft_edition.update_columns(
            created_at: draft_cips.pluck(:created_at).min,
            updated_at: PublishingApi::WorldwideOrganisationPresenter.new(worldwide_organisation, state: "draft", update_type: "minor").content[:public_updated_at],
          )
        else
          Rails.logger.info "Organisation has no draft CIPs"
        end

        ## Abort if anything in the presenter doesn't match for any of the models we've migrated
        check_results = []
        worldwide_organisation.translated_locales.each do |locale|
          I18n.with_locale(locale) do
            presented_worldwide_organisation = PublishingApi::WorldwideOrganisationPresenter.new(worldwide_organisation, update_type: "minor")
            presented_editionable_worldwide_organisation = PublishingApi::EditionableWorldwideOrganisationPresenter.new(editionable_worldwide_organisation_published_edition, update_type: "minor")

            check_results << integrity_check(presented_worldwide_organisation, presented_editionable_worldwide_organisation, "Published Worldwide Organisation for #{locale}")

            worldwide_organisation.offices.each do |office|
              presented_worldwide_office = PublishingApi::WorldwideOfficePresenter.new(office, update_type: "minor")
              editionable_office = editionable_worldwide_organisation_published_edition.offices.find_by(slug: office.slug)
              presented_editionable_worldwide_office = PublishingApi::WorldwideOfficePresenter.new(editionable_office, update_type: "minor")

              check_results << integrity_check(presented_worldwide_office, presented_editionable_worldwide_office, "Worldwide Office for #{office.slug} and #{locale}")

              presented_worldwide_office_contact = PublishingApi::ContactPresenter.new(office.contact, update_type: "minor")
              presented_editionable_worldwide_office_contact = PublishingApi::ContactPresenter.new(editionable_office.contact, update_type: "minor")

              check_results << integrity_check(presented_worldwide_office_contact, presented_editionable_worldwide_office_contact, "Worldwide Office Contact for #{office.slug} and #{locale}")
            end

            worldwide_organisation.corporate_information_pages.where(state: "published").find_each do |cip|
              next if cip.corporate_information_page_type_id == CorporateInformationPageType::AboutUs.id

              presented_cip = PublishingApi::WorldwideCorporateInformationPagePresenter.new(cip, update_type: "minor")
              editionable_page = editionable_worldwide_organisation_published_edition.pages.find_by(corporate_information_page_type_id: cip.corporate_information_page_type_id)
              presented_page = PublishingApi::WorldwideOrganisationPagePresenter.new(editionable_page, update_type: "minor")

              check_results << integrity_check(presented_cip, presented_page, "Published Worldwide Organisation Page for #{cip.slug} and #{locale}")
            end

            if editionable_worldwide_organisation_draft_edition
              presented_worldwide_organisation = PublishingApi::WorldwideOrganisationPresenter.new(worldwide_organisation, state: "draft", update_type: "minor")
              presented_editionable_worldwide_organisation = PublishingApi::EditionableWorldwideOrganisationPresenter.new(editionable_worldwide_organisation_draft_edition, update_type: "minor")

              check_results << integrity_check(presented_worldwide_organisation, presented_editionable_worldwide_organisation, "Draft Worldwide Organisation for #{locale}", skip_public_updated_at: true)

              worldwide_organisation.offices.each do |office|
                presented_worldwide_office = PublishingApi::WorldwideOfficePresenter.new(office, update_type: "minor")
                editionable_office = editionable_worldwide_organisation_draft_edition.offices.find_by(slug: office.slug)
                presented_editionable_worldwide_office = PublishingApi::WorldwideOfficePresenter.new(editionable_office, update_type: "minor")

                check_results << integrity_check(presented_worldwide_office, presented_editionable_worldwide_office, "Draft Worldwide Office for #{office.slug} and #{locale}", skip_public_updated_at: true)

                presented_worldwide_office_contact = PublishingApi::ContactPresenter.new(office.contact, update_type: "minor")
                presented_editionable_worldwide_office_contact = PublishingApi::ContactPresenter.new(editionable_office.contact, update_type: "minor")

                check_results << integrity_check(presented_worldwide_office_contact, presented_editionable_worldwide_office_contact, "Draft Worldwide Office Contact for #{office.slug} and #{locale}", skip_public_updated_at: true)
              end

              worldwide_organisation.corporate_information_pages.where(state: "draft").find_each do |cip|
                next if cip.corporate_information_page_type_id == CorporateInformationPageType::AboutUs.id

                presented_cip = PublishingApi::WorldwideCorporateInformationPagePresenter.new(cip, update_type: "minor")
                editionable_page = editionable_worldwide_organisation_draft_edition.pages.find_by(corporate_information_page_type_id: cip.corporate_information_page_type_id)
                presented_page = PublishingApi::WorldwideOrganisationPagePresenter.new(editionable_page, update_type: "minor")

                check_results << integrity_check(presented_cip, presented_page, "Draft Worldwide Organisation Page for #{cip.slug} and #{locale}", skip_public_updated_at: true)
              end
            end
          end

          old_associated_documents = EditionWorldwideOrganisation.where(worldwide_organisation:)
          new_associated_documents = EditionEditionableWorldwideOrganisation.where(document: editionable_worldwide_organisation_document)
          Rails.logger.info "Old worldwide organisation had #{old_associated_documents.count} associated documents"
          Rails.logger.info "New worldwide organisation has #{new_associated_documents.count} associated documents"
          check_results << false unless old_associated_documents.count == new_associated_documents.count
        end

        if check_results.include?(false)
          failed += 1

          ## Raise and rollback the transaction if the integrity check fails
          raise StandardError
        else
          completed += 1
        end
      end

      Rails.logger.info "Migrated #{completed} of #{total} organisations"
      Rails.logger.info "Failed to migrate #{failed} of #{total} organisations"
    end
  end

  def integrity_check(old_presenter, new_presenter, description, skip_public_updated_at: false)
    old_content = if skip_public_updated_at
                    old_presenter.content.except(:auth_bypass_ids, :public_updated_at)
                  else
                    old_presenter.content.except(:auth_bypass_ids)
                  end

    new_content = if skip_public_updated_at
                    new_presenter.content.except(:auth_bypass_ids, :public_updated_at)
                  else
                    new_presenter.content.except(:auth_bypass_ids)
                  end

    if old_presenter.content_id == new_presenter.content_id &&
        old_content == new_content &&
        old_presenter.links == new_presenter.links
      Rails.logger.info "Integrity check - pass for #{description}"

      true
    else
      Rails.logger.info "Integrity check - fail for #{description}"

      Rails.logger.info "Expected Content ID: #{old_presenter.content_id}"
      Rails.logger.info "Actual Content ID:   #{new_presenter.content_id}"

      Rails.logger.info "Expected Content:"
      Rails.logger.info old_content.sort.to_h.inspect
      Rails.logger.info "Actual Content:"
      Rails.logger.info new_content.sort.to_h.inspect

      Rails.logger.info "Expected Links:"
      Rails.logger.info old_presenter.links.sort.to_h.inspect
      Rails.logger.info "Actual Links:"
      Rails.logger.info new_presenter.links.sort.to_h.inspect

      false
    end
  end

  def convert_legacy_attachment_syntax(govspeak, attachments = [])
    return govspeak if govspeak.blank?

    govspeak = govspeak.gsub(/\n{0,2}^!@([0-9]+)\s*/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        "\n\n[Attachment: #{attachment.filename}]\n\n"
      else
        "\n\n"
      end
    end

    govspeak.gsub(/\[InlineAttachment:([0-9]+)\]/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        "[AttachmentLink: #{attachment.filename}]"
      else
        ""
      end
    end
  end
end

# rubocop:enable Rails/SkipsModelValidations

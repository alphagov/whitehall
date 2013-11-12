class ConvertSupportingPagesToEditions < ActiveRecord::Migration
  class ::OldSupportingPage < ActiveRecord::Base
    def policy
      Policy.unscoped.find_by_id(edition_id)
    end
  end
  OldSupportingPage.table_name = 'supporting_pages'

  # Exciting monkey patch #1 to allow setting of deleted policies
  module Edition::RelatedPolicies
    def related_policy_ids=(policy_ids)
      policy_ids = Array.wrap(policy_ids).reject(&:blank?)
      new_policies = policy_ids.map {|id| Policy.unscoped.find(id).document }
      other_related_documents = self.related_documents.reject { |document| document.latest_edition.is_a?(Policy) }

      self.related_documents = other_related_documents + new_policies
    end
  end

  # Exciting monkey patch #2 to allow invalid govspeak
  class Govspeak::HtmlValidator
    def valid?
      true
    end
  end

  def up
    gds_ig_team_user = User.find_by_name!('GDS Inside Government Team')
    policy_map = Hash.new { |hash, key| hash[key] = {} }

    transaction do
      # Supporting pages attached to policies that are no longer published should
      # be migrated last so that we don't create unnecessary redirects for
      # published supporting pages that don't currently clash
      OldSupportingPage.
          joins(%(JOIN editions
                    ON edition_id = editions.id
                  JOIN documents
                    ON editions.document_id = documents.id
                  LEFT OUTER JOIN editions published_policies
                    ON published_policies.document_id = documents.id
                    AND published_policies.state = "published"
                  LEFT OUTER JOIN supporting_pages published_pages
                    ON published_pages.edition_id = published_policies.id
                    AND published_pages.slug = supporting_pages.slug)).
          order(%(published_policies.id IS NULL,
                  published_pages.slug IS NULL,
                  editions.id,
                  supporting_pages.lock_version)).
          each do |old_sp|
        begin
          if old_sp.policy.nil?
            puts "Skipping old supporting page ##{old_sp.id} due to missing policy ##{old_sp.edition_id}"
            next
          end

          puts "Migrating old supporting page ##{old_sp.id}"

          sp_attributes = {
            title: old_sp.title,
            summary: nil,
            body: old_sp.body,
            created_at: old_sp.created_at,
            updated_at: old_sp.updated_at,
            lock_version: old_sp.lock_version,
            state: old_sp.policy.state,
            access_limited: old_sp.policy.access_limited?,
            first_published_at: old_sp.created_at,
            force_published: old_sp.policy.published?,
            creator: gds_ig_team_user,
            related_policy_ids: [old_sp.policy.id],
            major_change_published_at: old_sp.policy.major_change_published_at,
            minor_change: old_sp.policy.minor_change,
            change_note: old_sp.policy.change_note
          }

          # See if there's already a document for this supporting page
          doc = policy_map[old_sp.policy.document.id][old_sp.slug]

          # If there's no document but the slug is already taken then we have a
          # clash and need to generate a new slug and a redirect
          if doc.nil? && Document.where(document_type: 'SupportingPage').exists?(old_sp.slug)
            puts "  Slug #{old_sp.slug} already exists"

            # Try to generate a new slug from the title of the published version of the supporting page
            published_policy = old_sp.policy.document.published_edition
            published_sp = OldSupportingPage.where(edition_id: published_policy.id, slug: old_sp.slug).first unless published_policy.nil?
            unless published_sp.nil?
              new_slug = published_sp.title.parameterize

              unless Document.where(document_type: 'SupportingPage').exists?(new_slug)
                doc = Document.create!(document_type: 'SupportingPage', slug: new_slug,
                                       created_at: old_sp.created_at, updated_at: old_sp.created_at)
              end
            end

            if doc.nil?
              puts %(  Auto generating new slug from title "#{old_sp.title}")
            else
              puts "  Using published title to create slug '#{doc.slug}'"
            end

            sp = SupportingPage.create!(sp_attributes.merge(document_id: doc.try(:id)))

            SupportingPageRedirect.create!(policy_document: old_sp.policy.document,
                                           supporting_page_document: sp.document,
                                           original_slug: old_sp.slug)
          else
            # If there's no document and the slug is unused, we can just create the document
            if doc.nil?
              doc = Document.create!(document_type: 'SupportingPage', slug: old_sp.slug,
                                     created_at: old_sp.created_at, updated_at: old_sp.created_at)
            end

            sp = SupportingPage.create!(sp_attributes.merge(document_id: doc.id))
          end

          # Keep a reference to the document for future editions to use
          policy_map[old_sp.policy.document.id][old_sp.slug] = sp.document

          sp.editorial_remarks.create(
            author: gds_ig_team_user,
            body: "Automatically migrated from ##{old_sp.id} for new supporting page edition workflow for policy ##{old_sp.policy.id}")

          EditionedSupportingPageMapping.create!(old_supporting_page_id: old_sp.id, new_supporting_page_id: sp.id)

          ActiveRecord::Base.connection.execute("
            UPDATE attachments
            SET attachable_id = #{sp.id},
                attachable_type = 'Edition'
            WHERE attachable_id = #{old_sp.id}
            AND attachable_type = 'SupportingPage'
          ")

        rescue Exception => e
          puts "  Exception raised trying to migrate old supporting page ##{old_sp.id}: #{e.message}"
          raise e
        end
      end
    end

    puts "\nRedirects created:"
    SupportingPageRedirect.all.each do |redirect|
      policy_state = redirect.policy_document.published? ? "published" : "unpublished"
      puts <<-EOT
Changed supporting page slug "#{redirect.original_slug}"
                          to "#{redirect.supporting_page_document.slug}"
  on #{policy_state} policy "#{redirect.policy_document.slug}"
      EOT
    end
  end
end

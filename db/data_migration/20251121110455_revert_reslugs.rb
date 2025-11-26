require "data_hygiene/document_reslugger"
# This is a data cleanup related to issues introduced by opening up the reslugging feature (commits 356ffe9 d08467a abeb30a e064f5d 9a27fd3 4135fe0).
# A revert of the code was done in https://github.com/alphagov/whitehall/pull/10870 (commit 6f0ff88).
#
# A breakdown of the possible data issues we need to address:
# 1. Published editions with the "deleted" prefix
#   - Issue: Live slug is incorrect, as it was generated from a discarded draft
#   - We cannot just remove the "deleted" prefix as the name of the discarded draft may not be correct
#   - Need to be reslugged to pre-discard draft state by generating the slug from the title of the published edition
# 2. Draft or other pre-publication state editions (on previously published documents) with the "deleted" prefix
#   - Issue: It could go live during a (bulk) republish, even if those drafts may not be yet intended for publish
#   - Easiest approach is again to regenerate the slug from the title of the live edition
# 3. Any draft edition with a title change (on previously published documents)
#   - Issue: It could go live during a bulk republish, even if those drafts may not be yet intended for publish
#   - Issue: As already proven with the already published editions, users are likely to miss the slug change (especially since it is not visible anymore in the Summary page, after the revert)
#   - The slug needs to be generated from the title of the live edition
#   - This includes any draft editions with a title change where the user attempted to save an invalid form and then left the page.
# 4. Published editions of any slug
#   - We cannot know what the originating state of this edition was, if it came from a faulty republish from a draft, or an intentional slug change.
#   - As far as we can tell, the `edit_slug` action was only used intentionally for support tasks (checked)
#   - It is safest to also apply a reslug based on the title of the published edition.
# 5.  First drafts
#   - With deleted prefix: If there is no live edition, then the document has 0 editions after discard, no-op => this means we want to exclude deleted state from the query, as these discarded drafts are correctly slugged.
#   - Other: If there is no live edition, then the edition is fine, no-op
#
# In conclusion, we should:
# - apply a reslug based on the title of the live edition for all documents in the relevant timeframe
# - exclude deleted state from the query, as well as any first-drafts only
# - explicitly include slugs with the "deleted-" prefix in the query, as these are the ones affected by the issue
# - exclude CorporateInformationPage documents, as their slugging logic is different and not affected by the reslugging feature
# - risk: some intentional reslugs in the timeframe may be reverted (though as far as we can tell, these were only used for support tasks)

class RevertSlugs
  def self.run
    date_of_merge_of_reslug_changes = "2025-11-13 11:00:00.000000000 +0000"
    date_of_merge_of_revert_changes = "2025-11-20 17:00:00.000000000 +0000"
    documents = Document.where("updated_at > ?", date_of_merge_of_reslug_changes).where("updated_at < ?", date_of_merge_of_revert_changes).where("document_type != ?", "CorporateInformationPage").where("slug LIKE ?", "deleted-%")

    documents.each do |document|
      # There is nothing to fix for first drafts, as their slug is correct
      # Discarded drafts don't need fixing either, as their slug is correct
      next if document.editions.blank? || document.live_edition.nil?

      user = User.where(name: "Scheduled Publishing Robot", uid: nil).first
      published_edition = document.live_edition
      old_slug = document.slug
      normalize_friendly_id = published_edition.title.to_s.to_slug.truncate(150).normalize.to_s
      new_slug = normalize_friendly_id

      if old_slug == new_slug
        puts "SKIP: Old slug #{old_slug} and new slug from title #{new_slug} are the same"
        next
      end

      begin
        DataHygiene::DocumentReslugger.new(document, published_edition, user, new_slug).run!
        puts "SUCCESS: Reslugged document #{document.content_id} from old slug #{old_slug} to new slug #{new_slug}"
      rescue StandardError => e
        puts "ERROR: Could not reslug document #{document.content_id} from old slug #{old_slug} to new slug #{new_slug}: #{e}"
      end
    end
  end
end

RevertSlugs.run

# This worker synchronises the state of the editions for a document with the
# publishing-api. It sends the current published Edition and the draft Edition.
#
# It is important that the requests are sent in the right order. If the
# pre_publication_edition is sent and then a publish request is sent, the wrong
# draft gets published. If the pre_publication_edition is sent and then the
# published_edition is sent and published, then the pre_publication_edition is
# lost.
#
# The design of the publishing-api means that it is impossible to republish
# something that currently has a draft without having to store the current draft
# and sending it again after republishing. This also changes the version
# numbering and would probably appear in the version history.
class PublishingApiDocumentRepublishingWorker < WorkerBase
  def perform(published_edition_id, pre_publication_edition_id)
    if published_edition_id
      published_edition = Edition.find(published_edition_id)
      Whitehall::PublishingApi.locales_for(published_edition).each do |locale|
        # We need to do this synchronously because we need to guarantee it
        # completes before pushing the pre_publication_edition.
        PublishingApiWorker.new.perform('Edition', published_edition_id, 'republish', locale.to_s)
      end
    end

    if pre_publication_edition_id
      pre_publication_edition = Edition.find(pre_publication_edition_id)
      # Now that we know we've completed pushing the currently published
      # editions, we can safely push the drafts.
      #
      # PublishingApi.save_draft_async handles locales for us
      Whitehall::PublishingApi.save_draft_async(pre_publication_edition, 'republish')
    end
  end
end

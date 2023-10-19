# In the previous commit we introduced a new "unpublished" state to the edition workflow. Now, when an edition is unpublished,
# instead of reverting the edition to the draft state, we transition it to the unpublished state instead. The user
# can then create a new draft via the user interface. When published, the new edition will supersede the unpublished
# edition.
#
# We are therefore migrating all draft editions with an associated `Unpublishing` record to the unpublished state, and
# asking that the Publishing API discard its draft of the content item.

unpublished_editions = Edition.joins(:unpublishing).draft

unpublished_editions.find_each(batch_size: 100) do |edition|
  PublishingApiDiscardDraftWorker.perform_async(edition.content_id, edition.primary_locale)
end

unpublished_editions.update_all(state: "unpublished")

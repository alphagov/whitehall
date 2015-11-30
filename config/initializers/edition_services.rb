Whitehall.edition_services.tap do |es|
  es.subscribe(/^(force_publish|publish)$/)                   { |event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
  es.subscribe(/^(force_publish|publish|unpublish|withdraw)$/) { |event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
  es.subscribe(/^(force_publish|publish)$/)                   { |event, edition, options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
  es.subscribe(/^(force_publish|publish|unpublish|withdraw)$/) { |_, edition, _| ServiceListeners::PanopticonRegistrar.new(edition).register! }
  es.subscribe(/^(force_publish|publish)$/)                   { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }

  # search
  es.subscribe(/^(force_publish|publish)$/) { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).index! }
  es.subscribe("unpublish")                 { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).remove! }

  # publishing API
  es.subscribe(/^(force_publish|publish)$/)   { |_, edition, _| Whitehall::PublishingApi.publish_async(edition) }
  es.subscribe("update_draft")                { |_, edition, _| Whitehall::PublishingApi.save_draft_async(edition) }
  es.subscribe("withdraw")                     { |_, edition, _| Whitehall::PublishingApi.republish_async(edition) }
  es.subscribe("unpublish")                   { |_, edition, _| Whitehall::PublishingApi.publish_async(edition.unpublishing) }
  es.subscribe(/^(force_schedule|schedule)$/) { |_, edition, _| Whitehall::PublishingApi.schedule_async(edition) }
  es.subscribe("unschedule")                  { |_, edition, _| Whitehall::PublishingApi.unschedule_async(edition) }
  es.subscribe("delete")                      { |_, edition, _| Whitehall::PublishingApi.discard_draft_async(edition) }

  # handling edition's dependency on other content
  es.subscribe(/^(force_publish|publish)$/) { |_, edition, _| EditionDependenciesPopulator.new(edition).populate! }
  es.subscribe(/^(force_publish|publish)$/) { |_, edition, _| edition.republish_dependent_editions }
  es.subscribe("unpublish")                 { |_, edition, _| edition.edition_dependencies.destroy_all }
end

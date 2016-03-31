Whitehall.edition_services.tap do |es|
  es.subscribe(/^(force_publish|publish)$/)                   { |event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
  es.subscribe(/^(force_publish|publish|unpublish|withdraw)$/) { |event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
  es.subscribe(/^(force_publish|publish)$/)                   { |event, edition, options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
  es.subscribe(/^(force_publish|publish|unpublish|withdraw)$/) { |_, edition, _| ServiceListeners::PanopticonRegistrar.new(edition).register! }
  es.subscribe(/^(force_publish|publish)$/)                   { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }

  # search
  es.subscribe(/^(force_publish|publish|withdraw)$/) { |_, edition, _| ServiceListeners::SearchIndexer.new(edition).index! }
  es.subscribe("unpublish")                 { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).remove! }

  # publishing API
  es.subscribe { |event, edition, options| ServiceListeners::PublishingApiPusher.new(edition).push(event: event, options: options) }

  # handling edition's dependency on other content
  es.subscribe(/^(force_publish|publish)$/) { |_, edition, _| EditionDependenciesPopulator.new(edition).populate! }
  es.subscribe(/^(force_publish|publish)$/) { |_, edition, _| edition.republish_dependent_editions }
  es.subscribe("unpublish")                 { |_, edition, _| edition.edition_dependencies.destroy_all }
end

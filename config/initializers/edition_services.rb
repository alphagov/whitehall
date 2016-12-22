Whitehall.edition_services.tap do |es|
  es.subscribe(/^(force_publish|publish|unwithdraw)$/)                   { |event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
  es.subscribe(/^(force_publish|publish|unwithdraw|unpublish|withdraw)$/) { |event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
  es.subscribe(/^(force_publish|publish|unwithdraw)$/)                   { |event, edition, options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
  es.subscribe(/^(force_publish|publish|unwithdraw)$/)                   { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }

  # search
  es.subscribe(/^(force_publish|publish|withdraw|unwithdraw)$/) { |_, edition, _| ServiceListeners::SearchIndexer.new(edition).index! }
  es.subscribe("unpublish")                 { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).remove! }

  # publishing API
  es.subscribe { |event, edition, options| ServiceListeners::PublishingApiPusher.new(edition).push(event: event, options: options) }

  # handling edition's dependency on other content
  es.subscribe(/^(force_publish|publish|unwithdraw)$/) { |_, edition, _| EditionDependenciesPopulator.new(edition).populate! }
  es.subscribe(/^(force_publish|publish|unwithdraw)$/) { |_, edition, _| edition.republish_dependent_editions }
  es.subscribe("unpublish")                 { |_, edition, _| edition.edition_dependencies.destroy_all }
end

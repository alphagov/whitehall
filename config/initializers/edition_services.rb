Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
Whitehall.edition_services.subscribe(/^(force_publish|publish|unpublish|archive)$/) { |event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
Whitehall.edition_services.subscribe(/^(force_publish|publish|unpublish|archive)$/) { |_, edition, _| ServiceListeners::PanopticonRegistrar.new(edition).register! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).index! }
Whitehall.edition_services.subscribe("unpublish") { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).remove! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| Whitehall::PublishingApi.publish(edition) }
Whitehall.edition_services.subscribe(/^(archive)$/) { |_, edition, _| Whitehall::PublishingApi.republish(edition) }

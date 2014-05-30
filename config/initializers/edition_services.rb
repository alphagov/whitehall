Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
Whitehall.edition_services.subscribe(/^(force_publish|publish|unpublish|archive)$/) { |_event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_event, edition, _options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::PanopticonRegistrar.new(edition).register! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_event, edition, _options| ServiceListeners::SearchIndexer.new(edition).index! }
Whitehall.edition_services.subscribe("unpublish") { |_event, edition, _options| ServiceListeners::SearchIndexer.new(edition).remove! }
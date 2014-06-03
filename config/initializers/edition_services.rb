Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
Whitehall.edition_services.subscribe(/^(force_publish|publish|unpublish|archive)$/) { |_, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::PanopticonRegistrar.new(edition).register! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::AnnouncementClearer.new(edition).clear! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |_, edition, _| ServiceListeners::SearchIndexer.new(edition).index! }
Whitehall.edition_services.subscribe("unpublish") { |_, edition, _| ServiceListeners::SearchIndexer.new(edition).remove! }

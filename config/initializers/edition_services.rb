
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| ServiceListeners::AuthorNotifier.new(edition, options[:user]).notify! }
Whitehall.edition_services.subscribe(/^(force_publish|publish|unpublish)$/) { |event, edition, options| ServiceListeners::EditorialRemarker.new(edition, options[:user], options[:remark]).save_remark! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| ServiceListeners::SearchIndexer.new(edition).index! }
Whitehall.edition_services.subscribe(/^(force_publish|publish)$/) { |event, edition, options| Whitehall::GovUkDelivery::Notifier.new(edition).edition_published! }

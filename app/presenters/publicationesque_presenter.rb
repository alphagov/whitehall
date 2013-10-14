class PublicationesquePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of *Publicationesque.concrete_descendants

  def as_hash
    super.merge(publication_collections: publication_collections)
  end

  def publication_collections
    if model.part_of_published_collection?
      links = model.published_document_collections.map do |dc|
        context.link_to(dc.title, context.public_document_path(dc))
      end
      "Part of a collection: #{links.to_sentence}"
    end
  end

  def time_until_closure
    days_left = model.closing_on - Time.zone.now.to_date
    case days_left
    when ->(n) {n < 0}
      "Closed"
    when 0
      "Closing today"
    when 1
      "Closes tomorrow"
    else
      "#{days_left.to_i} days left"
    end
  end
end

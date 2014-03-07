class LatestDocumentPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of Edition

  def document_collections
    if has_document_collections?
      links = model.published_document_collections.map do |collection|
        context.link_to(collection.title,
                        context.public_document_path(collection))
      end

      "Part of a collection: #{links.to_sentence}".html_safe
    end
  end

  def organisations
    model.organisations
  end

private
  def has_document_collections?
    model.respond_to?(:published_document_collections) &&
      model.published_document_collections.any?
  end
end

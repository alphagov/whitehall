class Admin::Export::DocumentController < Admin::Export::BaseController
  include GovspeakHelper
  include PublicDocumentRoutesHelper

  self.responder = Api::Responder

  def show
    @document = Document.find(params[:id])
    output = {
               "document": @document,
               "editions": []
             }
    @document.editions.each do |edition|
      output[:editions].push(edition_associations(edition))
    end
    respond_with output
  end

private

  def edition_associations(edition)
    output = {
               "edition": edition,
               "associations": {},
               "whitehall_admin_links": []
             }
    associations = edition.class.reflect_on_all_associations.map(&:name)
    associations.each do |association|
      output[:associations][association] = edition.public_send(association)
    end
    output[:whitehall_admin_links].concat(resolve_whitehall_admin_links(edition.body))
    if edition.withdrawn?
      output[:whitehall_admin_links].concat(resolve_whitehall_admin_links(edition.unpublishing.explanation))
    end
    output
  end

  def resolve_whitehall_admin_links(body)
    whitehall_admin_links(body).map { |link|
      { "whitehall_admin_url": link, "public_url": public_url_for_admin_link(link) }
    }
  end

  def public_url_for_admin_link(url)
    edition = Whitehall::AdminLinkLookup.find_edition(url)
    if edition.present?
      public_document_url(edition)
    end
  end
end

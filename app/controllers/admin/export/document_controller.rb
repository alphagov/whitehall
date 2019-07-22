class Admin::Export::DocumentController < Admin::Export::BaseController
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
               "edition": edition
             }
    output[:associations] = {}
    associations = edition.class.reflect_on_all_associations.map(&:name)
    associations.each do |association|
      output[:associations][association] = edition.public_send(association)
    end
    output
  end
end

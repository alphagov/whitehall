class Admin::DocumentCollectionGroupMembershipsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group
  before_action :find_document, only: :create

  def create
    membership = DocumentCollectionGroupMembership.new(document: @document, document_collection_group: @group)
    if membership.save
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: "'#{params[:title]}' added to '#{@group.heading}'"
    else
      redirect_to admin_document_collection_groups_path(@collection),
                  alert: membership.errors.full_messages.join(". ") + '.'
    end
  end

  def destroy
    document_ids = params.fetch(:documents, []).map(&:to_i)
    if document_ids.present?
      delete_from_old_group(document_ids)
      move_to_new_group(document_ids) if moving?
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: success_message(document_ids)
    else
      redirect_to admin_document_collection_groups_path(@collection),
                  alert: 'Select one or more documents and try again'
    end
  end

private

  def moving?
    params[:commit] == 'Move'
  end

  def delete_from_old_group(document_ids)
    @group.memberships.where(document_id: document_ids).destroy_all
  end

  def move_to_new_group(document_ids)
    new_group.documents << Document.where('id in (?)', document_ids)
  end

  def success_message(document_ids)
    count = "#{document_ids.size} #{'document'.pluralize(document_ids.size)}"
    if moving?
      "#{count} moved to '#{new_group.heading}'"
    else
      "#{count} removed from '#{@group.heading}'"
    end
  end

  def new_group
    @collection.groups.find(params[:new_group_id])
  end

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:group_id])
    session[:document_collection_selected_group_id] = params[:group_id]
  end

  def find_document
    unless (@document = Document.where(id: params[:document_id]).first)
      redirect_to admin_document_collection_groups_path(@collection),
                  alert: "We couldn't find a document titled '#{params[:title]}'"
    end
  end
end

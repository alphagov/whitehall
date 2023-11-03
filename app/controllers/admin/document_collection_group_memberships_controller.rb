class Admin::DocumentCollectionGroupMembershipsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group
  before_action :load_membership, only: %i[confirm_destroy]
  before_action :find_document, only: :create_whitehall_member

  layout "design_system"

  def index; end

  def create_whitehall_member
    membership = DocumentCollectionGroupMembership.new(document: @document, document_collection_group: @group)
    redirect_path = admin_document_collection_group_document_collection_group_memberships_path(@collection, @group)
    if membership.save
      title = @document.latest_edition.title
      redirect_to redirect_path,
                  notice: "'#{title}' added to '#{@group.heading}'"
    else
      redirect_to redirect_path,
                  alert: "#{membership.errors.full_messages.join('. ')}."
    end
  end

  def create_non_whitehall_member
    govuk_link = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: params[:url],
      document_collection_group: @group,
    )
    if govuk_link.save
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: "'#{govuk_link.title}' added to '#{@group.heading}'"
    else
      flash[:url] = params[:url]
      flash[:open_non_whitehall] = true
      redirect_to admin_document_collection_groups_path(@collection),
                  alert: "#{govuk_link.errors.full_messages.join('. ')}."
    end
  end

  def create_member_by_govuk_url
    govuk_link = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: params[:document_url],
      document_collection_group: @group,
    )
    if govuk_link.save
      redirect_to admin_document_collection_group_document_collection_group_memberships_path(@collection, @group),
                  notice: "'#{govuk_link.title}' added to '#{@group.heading}'"
    else
      redirect_to admin_document_collection_group_add_by_url_path(@collection, @group),
                  alert: "#{govuk_link.errors.full_messages.join('. ')}."
    end
  end

  def confirm_destroy; end

  def destroy
    @membership = load_membership
    @membership.destroy!

    redirect_to admin_document_collection_group_members_path(@collection, @group),
                notice: "Document has been removed from the group"
  end

  def reorder; end

  def order
    params[:ordering].each do |membership_ids, ordering|
      @group.memberships.find(membership_ids).update_column(:ordering, ordering)
    end

    flash_message = "Document has been reordered"
    redirect_to admin_document_collection_group_members_path(@collection), notice: flash_message
  end

private

  def moving?
    params[:commit] == "Move"
  end

  def delete_from_old_group(membership_ids)
    ids = @group.membership_ids - membership_ids
    @group.set_membership_ids_in_order!(ids)
  end

  def move_to_new_group(membership_ids)
    ids = new_group.membership_ids + membership_ids
    new_group.set_membership_ids_in_order!(ids)
  end

  def success_message(membership_ids)
    count = "#{membership_ids.size} #{'document'.pluralize(membership_ids.size)}"
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
    @collection = DocumentCollection.includes(document: :latest_edition).find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:group_id])
    session[:document_collection_selected_group_id] = params[:group_id]
  end

  def load_membership
    @membership = @group.memberships.find(params[:id])
  end

  def find_document
    unless (@document = Document.where(id: params[:document_id]).first)
      redirect_to admin_document_collection_groups_path(@collection),
                  alert: "We couldn't find a document titled '#{params[:title]}'"
    end
  end
end

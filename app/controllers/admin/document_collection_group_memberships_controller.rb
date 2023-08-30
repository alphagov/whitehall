class Admin::DocumentCollectionGroupMembershipsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group
  before_action :load_membership, only: %i[confirm_destroy]
  before_action :find_document, only: :create_whitehall_member
  layout :get_layout

  def index; end

  def create_whitehall_member
    membership = DocumentCollectionGroupMembership.new(document: @document, document_collection_group: @group)
    if membership.save
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: "'#{params[:title]}' added to '#{@group.heading}'"
    else
      redirect_to admin_document_collection_groups_path(@collection),
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

  def confirm_destroy; end

  def destroy
    if get_layout == "design_system"
      @membership = load_membership
      @membership.destroy!

      redirect_to admin_document_collection_group_members_path(@collection, @group),
                  notice: "Document has been removed from the group"
    else
      membership_ids = params.fetch(:memberships, []).map(&:to_i)
      if membership_ids.present?
        moving? ? move_to_new_group(membership_ids) : delete_from_old_group(membership_ids)
        redirect_to admin_document_collection_groups_path(@collection),
                    notice: success_message(membership_ids)
      else
        redirect_to admin_document_collection_groups_path(@collection),
                    alert: "Select one or more documents and try again"
      end
    end
  end

private

  def get_layout
    design_system_actions = %w[index confirm_destroy]
    design_system_actions += %w[destroy] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

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

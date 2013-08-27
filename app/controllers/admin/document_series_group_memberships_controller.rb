class Admin::DocumentSeriesGroupMembershipsController < Admin::BaseController
  before_filter :load_document_series
  before_filter :load_document_series_group

  def destroy
    document_ids = params.fetch(:documents, []).map(&:to_i)
    if document_ids.present?
      delete_from_old_group(document_ids)
      move_to_new_group(document_ids) if moving?
      redirect_to admin_document_series_groups_path(@series),
                  notice: success_message(document_ids)
    else
      redirect_to admin_document_series_groups_path(@series),
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
    @series.groups.find(params[:new_group_id])
  end

  def load_document_series
    @series = DocumentSeries.find(params[:document_series_id])
  end

  def load_document_series_group
    @group = @series.groups.find(params[:group_id])
  end
end

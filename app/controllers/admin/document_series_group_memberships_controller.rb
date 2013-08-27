class Admin::DocumentSeriesGroupMembershipsController < Admin::BaseController
  before_filter :load_document_series
  before_filter :load_document_series_group

  def destroy
    sql = 'document_series_group_memberships.document_id in (?)'
    ids = params.fetch(:documents, []).map(&:to_i)
    if ids.present?
      @group.memberships.where(sql, ids).destroy_all
      redirect_to admin_document_series_groups_path(@series),
                  notice: deletion_message(ids)
    else
      redirect_to admin_document_series_groups_path(@series),
                  alert: 'Select one or more documents to remove'
    end
  end

  private

  def deletion_message(ids)
    deleted = "#{ids.size} #{'document'.pluralize(ids.size)}"
    "#{deleted} removed from '#{@group.heading}'"
  end

  def load_document_series
    @series = DocumentSeries.find(params[:document_series_id])
  end

  def load_document_series_group
    @group = @series.groups.find(params[:group_id])
  end
end

class Admin::OffsiteLinksController < Admin::BaseController
  before_action :load_parent
  before_action :load_offsite_link, except: %i[new create]
  layout :get_layout

  def new
    @offsite_link = OffsiteLink.new

    render_design_system(:new, :legacy_new)
  end

  def create
    @offsite_link = OffsiteLink.new(offsite_link_params)
    @parent.offsite_links << @offsite_link
    if @parent.save
      flash[:notice] = "An offsite link has been created for #{@parent.name}"
      redirect_to offsite_links_path
    else
      render_design_system(:new, :legacy_new)
    end
  end

  def edit
    render_design_system(:edit, :legacy_edit)
  end

  def update
    if @offsite_link.update(offsite_link_params)
      redirect_to offsite_link_path(@offsite_link)
    else
      render_design_system(:edit, :legacy_edit)
    end
  end

  def confirm_destroy; end

  def destroy
    @offsite_link.destroy!
    flash[:notice] = "#{@offsite_link.title} has been deleted"
    redirect_to offsite_links_path
  end

private

  def get_layout
    if preview_design_system?(next_release: true)
      "design_system"
    else
      "admin"
    end
  end

  def load_parent
    @parent = WorldLocation.friendly.find(params[:world_location_news_id]).world_location_news if params[:world_location_news_id]
    @parent = Organisation.friendly.find(params[:organisation_id]) if params[:organisation_id]
    @parent = TopicalEvent.friendly.find(params[:topical_event_id]) if params[:topical_event_id]
  end

  def load_offsite_link
    @offsite_link = OffsiteLink.find(params[:id])
  end

  def offsite_link_path(offsite_link)
    if offsite_link.parent.is_a? TopicalEvent
      polymorphic_path([:admin, offsite_link.parent, :topical_event_featurings])
    else
      polymorphic_url([:features, :admin, offsite_link.parent])
    end
  end

  def offsite_links_path
    if @parent.is_a? TopicalEvent
      polymorphic_path([:admin, @parent, :topical_event_featurings], anchor: preview_design_system?(next_release: false) ? "non_govuk_government_links_tab" : nil)
    else
      polymorphic_path([:features, :admin, @parent], anchor: preview_design_system?(next_release: false) ? "non_govuk_government_links_tab" : nil)
    end
  end

  def offsite_link_params
    params.require(:offsite_link)
          .permit(:title, :summary, :link_type, :url, :date)
  end
end

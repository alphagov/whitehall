class Admin::OrganisationsController < Admin::BaseController
  before_filter :load_organisation, except: [:index, :new, :create]

  def index
    @organisations = Organisation.includes(:organisation_type).alphabetical
    @user_organisation = current_user.organisation
  end

  def new
    @organisation = Organisation.new
    build_organisation_roles
    build_organisation_classifications
    build_mainstream_links
    social.build_social_media_account(@organisation)
  end

  def create
    destroy_blank_mainstream_links
    social.destroy_blank_social_media_accounts(params[:organisation])
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      build_organisation_roles
      social.build_social_media_account(@organisation)
      render action: "new"
    end
  end

  def show
  end

  def about
  end

  def people
    load_organisation_roles
  end

  def document_series
    @document_series = @organisation.document_series
  end

  def features
    @feature_list = @organisation.load_or_create_feature_list(params[:locale])

    filter_params = params.slice(:page, :type, :author, :organisation, :title).
      merge(state: 'published')
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = TopicalEvent.active.all
  end

  def edit
    build_organisation_classifications
    build_mainstream_links
    social.build_social_media_account(@organisation)
    load_organisation_roles
    build_default_news_image
  end

  def update
    destroy_blank_mainstream_links
    delete_absent_organisation_classifications
    social.destroy_blank_social_media_accounts(params[:organisation])
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisation_path(@organisation)
    else
      load_organisation_roles
      social.build_social_media_account(@organisation)
      render action: "edit"
    end
  end

  def destroy
    @organisation.destroy
    redirect_to admin_organisations_path
  end

  private

  def build_organisation_roles
    @ministerial_organisation_roles = []
    @management_organisation_roles = []
    @traffic_commissioner_organisation_roles = []
    @military_organisation_roles = []
    @special_representative_organisation_roles = []
    @chief_professional_officer_roles = []
  end

  def build_organisation_classifications
    n = @organisation.organisation_classifications.count
    @organisation.organisation_classifications.each.with_index do |ot, i|
      ot.ordering = i
    end
    (n...13).each do |i|
      @organisation.organisation_classifications.build(ordering: i)
    end
  end

  def build_default_news_image
    @organisation.build_default_news_image
  end

  def delete_absent_organisation_classifications
    return unless params[:organisation] &&
                  params[:organisation][:organisation_classifications_attributes]
    params[:organisation][:organisation_classifications_attributes].each do |p|
      if p[:classification_id].blank?
        p["_destroy"] = true
      end
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end

  def build_mainstream_links
    unless @organisation.mainstream_links.any?(&:new_record?)
      @organisation.mainstream_links.build
    end
  end

  def load_organisation_roles
    @ministerial_organisation_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.ministerial).order(:ordering)
    @management_organisation_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.management).order(:ordering)
    @traffic_commissioner_organisation_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.traffic_commissioner).order(:ordering)
    @military_organisation_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.military).order(:ordering)
    @special_representative_organisation_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.special_representative).order(:ordering)
    @chief_professional_officer_roles = @organisation.organisation_roles.joins(:role).
                                        merge(Role.chief_professional_officer).order(:ordering)
  end

  def destroy_blank_mainstream_links
    if params[:organisation][:mainstream_links_attributes]
      params[:organisation][:mainstream_links_attributes].each do |index, link|
        if link[:title].blank? && link[:url].blank?
          link[:_destroy] = "1"
        end
      end
    end
  end

  def social
    @social ||= Whitehall::Controllers::SocialMedia.new
  end
end

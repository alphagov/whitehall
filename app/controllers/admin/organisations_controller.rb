class Admin::OrganisationsController < Admin::BaseController
  before_filter :load_organisation, except: [:index, :new, :create]

  def index
    @organisations = Organisation.alphabetical
    @user_organisation = current_user.organisation
  end

  def new
    @organisation = Organisation.new
    build_organisation_classifications
    build_organisation_mainstream_categories
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      render :new
    end
  end

  def show
  end

  def about
  end

  def people
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

  def features
    @feature_list = @organisation.load_or_create_feature_list(params[:locale])

    filter_params = params.slice(:page, :type, :author, :organisation, :title).
      merge(state: 'published')
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = TopicalEvent.active.all

    if request.xhr?
      render partial: 'admin/feature_lists/search_results', locals: {feature_list: @feature_list}
    else
      render :features
    end
  end

  def edit
    build_organisation_classifications
    build_organisation_mainstream_categories
    build_default_news_image
  end

  def update
    delete_absent_organisation_classifications
    delete_absent_organisation_mainstream_categories
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisation_path(@organisation)
    else
      render :edit
    end
  end

  def destroy
    @organisation.destroy
    redirect_to admin_organisations_path
  end

  private

  def build_organisation_classifications
    n = @organisation.organisation_classifications.count
    @organisation.organisation_classifications.each.with_index do |ot, i|
      ot.ordering = i
    end
    (n...13).each do |i|
      @organisation.organisation_classifications.build(ordering: i)
    end
  end

  def build_organisation_mainstream_categories
    n = @organisation.organisation_mainstream_categories.count
    @organisation.organisation_mainstream_categories.each.with_index do |omc, i|
      omc.ordering = i
    end
    (n...13).each do |i|
      @organisation.organisation_mainstream_categories.build(ordering: i)
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

  def delete_absent_organisation_mainstream_categories
    return unless params[:organisation] &&
                  params[:organisation][:organisation_mainstream_categories_attributes]
    params[:organisation][:organisation_mainstream_categories_attributes].each do |p|
      if p[:mainstream_category_id].blank?
        p["_destroy"] = true
      end
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end

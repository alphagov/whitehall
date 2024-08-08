class Admin::RepublishingController < Admin::BaseController
  include Admin::EditionsHelper
  include Admin::RepublishingHelper
  include ReshuffleMode

  before_action :enforce_permissions!

  def index
    @republishable_pages = republishable_pages
  end

  def confirm_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    @republishing_event = RepublishingEvent.new
    @title = page_to_republish[:title]
    @republishing_path = admin_republishing_page_republish_path(page_to_republish[:slug])
  end

  def republish_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }
    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    if reshuffle_in_progress? && %w[how-government-works ministers].include?(params[:page_slug])
      flash[:alert] = "Cannot republish #{params[:page_slug]} page while in reshuffle mode"
      return redirect_to(admin_republishing_index_path)
    end

    action = "The page '#{page_to_republish[:title]}' has been scheduled for republishing"

    @republishing_event = build_republishing_event(action:, content_id: page_to_republish[:presenter].constantize.new.content_id)

    if @republishing_event.save
      PresentPageToPublishingApiWorker.perform_async(page_to_republish[:presenter])
      flash[:notice] = action

      redirect_to(admin_republishing_index_path)
    else
      @title = page_to_republish[:title]
      @republishing_path = admin_republishing_page_republish_path(page_to_republish[:slug])

      render "confirm_page"
    end
  end

  def find_organisation; end

  def search_organisation
    unless Organisation.find_by(slug: params[:organisation_slug])
      flash[:alert] = "Organisation with slug '#{params[:organisation_slug]}' not found"
      return redirect_to(admin_republishing_organisation_find_path)
    end

    redirect_to(admin_republishing_organisation_confirm_path(params[:organisation_slug]))
  end

  def confirm_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug])
    render "admin/errors/not_found", status: :not_found unless @organisation

    @republishing_event = RepublishingEvent.new
  end

  def republish_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug])
    return render "admin/errors/not_found", status: :not_found unless @organisation

    action = "The organisation '#{@organisation.name}' has been republished"
    @republishing_event = build_republishing_event(action:, content_id: @organisation.content_id)

    if @republishing_event.save
      @organisation.publish_to_publishing_api
      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_organisation"
    end
  end

  def find_person; end

  def search_person
    unless Person.find_by(slug: params[:person_slug])
      flash[:alert] = "Person with slug '#{params[:person_slug]}' not found"
      return redirect_to(admin_republishing_person_find_path)
    end

    redirect_to(admin_republishing_person_confirm_path(params[:person_slug]))
  end

  def confirm_person
    @person = Person.find_by(slug: params[:person_slug])
    render "admin/errors/not_found", status: :not_found unless @person

    @republishing_event = RepublishingEvent.new
  end

  def republish_person
    @person = Person.find_by(slug: params[:person_slug])
    return render "admin/errors/not_found", status: :not_found unless @person

    action = "The person '#{@person.name}' has been republished"
    @republishing_event = build_republishing_event(action:, content_id: @person.content_id)

    if @republishing_event.save
      @person.publish_to_publishing_api
      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_person"
    end
  end

  def find_role; end

  def search_role
    unless Role.find_by(slug: params[:role_slug])
      flash[:alert] = "Role with slug '#{params[:role_slug]}' not found"
      return redirect_to(admin_republishing_role_find_path)
    end

    redirect_to(admin_republishing_role_confirm_path(params[:role_slug]))
  end

  def confirm_role
    @role = Role.find_by(slug: params[:role_slug])
    render "admin/errors/not_found", status: :not_found unless @role

    @republishing_event = RepublishingEvent.new
  end

  def republish_role
    @role = Role.find_by(slug: params[:role_slug])
    return render "admin/errors/not_found", status: :not_found unless @role

    action = "The role '#{@role.name}' has been republished"
    @republishing_event = build_republishing_event(action:, content_id: @role.content_id)

    if @republishing_event.save
      @role.publish_to_publishing_api
      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_role"
    end
  end

  def find_document; end

  def search_document
    unless Document.find_by(slug: params[:document_slug])
      flash[:alert] = "Document with slug '#{params[:document_slug]}' not found"
      return redirect_to(admin_republishing_document_find_path)
    end

    redirect_to(admin_republishing_document_confirm_path(params[:document_slug]))
  end

  def confirm_document
    @document = Document.find_by(slug: params[:document_slug])
    render "admin/errors/not_found", status: :not_found unless @document

    @republishing_event = RepublishingEvent.new
  end

  def republish_document
    @document = Document.find_by(slug: params[:document_slug])
    return render "admin/errors/not_found", status: :not_found unless @document

    action = "Editions for the document with slug '#{@document.slug}' have been republished"
    @republishing_event = build_republishing_event(action:, content_id: @document.content_id)

    if @republishing_event.save
      PublishingApiDocumentRepublishingWorker.new.perform(@document.id)
      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_document"
    end
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def republishable_pages
    [
      "PublishingApi::HistoricalAccountsIndexPresenter",
      "PublishingApi::HowGovernmentWorksPresenter",
      "PublishingApi::OperationalFieldsIndexPresenter",
      "PublishingApi::MinistersIndexPresenter",
      "PublishingApi::EmbassiesIndexPresenter",
      "PublishingApi::WorldIndexPresenter",
      "PublishingApi::OrganisationsIndexPresenter",
    ].map do |presenter_class_string|
      presenter_instance = presenter_class_string.constantize.new

      {
        title: presenter_instance.title,
        public_path: presenter_instance.base_path,
        slug: presenter_instance.base_path.split("/").last,
        presenter: presenter_class_string,
      }
    end
  end

  def build_republishing_event(action:, content_id:)
    RepublishingEvent.new(user: current_user, reason: params.fetch(:reason), action:, content_id:, bulk: false)
  end
end

module Admin::CancelRoutesHelper
  include ActionDispatch::Routing::PolymorphicRoutes
  include Admin::EditionRoutesHelper

  def admin_cancel_path(object)
    if object.new_record?
      case object
      when CorporateInformationPage
        polymorphic_path([:admin, object.owning_organisation, CorporateInformationPage])
      when Edition
        admin_editions_path
      else
        polymorphic_path([:admin, object.class])
      end
    else
      case object
      when CorporateInformationPage, Edition
        admin_edition_path(object)
      else
        polymorphic_path([:admin, object])
      end
    end
  end
end

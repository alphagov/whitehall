class Admin::DraftEditionChangeNotesController < Admin::BaseController
  before_action :find_edition, :enforce_permissions!, :redirect_to_show_page_unless_editable
  layout "design_system"

  def edit
    @change_note_form = ChangeNoteForm.build_from_edition(@edition)
  end

  def update
    @change_note_form = ChangeNoteForm.new(change_note_params)

    if @change_note_form.save!(@edition)
      redirect_to admin_edition_path(@edition), notice: "Change note updated successfully"
    else
      render :edit
    end
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def redirect_to_show_page_unless_editable
    redirect_to admin_edition_path(@edition) unless @edition.editable?
  end

  def change_note_params
    params.require(:change_note_form).permit(:minor_change, :change_note)
  end
end

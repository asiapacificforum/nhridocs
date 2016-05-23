require 'notes_controller'

class Nhri::ProtectionPromotion::Project::NotesController < NotesController
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  private
  def note_params
    params[:note][:notable_id] = params[:project_id]
    params[:note][:notable_type] = "Nhri::ProtectionPromotion::Project"
    super
  end
end
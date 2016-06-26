class Complaint::CommunicationsController < ApplicationController
  def create
    communication = Communication.new(communication_params)
    if communication.save
      render :json => communication.complaint.communications, :status => 200
    else
      render :status => 500
    end
  end

  def destroy
    communication = Communication.find(params[:id])
    complaint = communication.complaint
    if communication.destroy
      render :json => complaint.reload.communications, :status => 200
    else
      render :status => 500
    end
  end

  private
  def communication_params
    params.require(:communication).permit(:user_id, :complaint_id, :direction, :mode, :date, :note)
  end
end

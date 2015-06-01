class CorporateServices::InternalDocuments::FilesizesController < ApplicationController

  def update
    if params[:filesize].match(/^\d+$/) && params[:filesize].to_i < 100
      SiteConfig['corporate_services.internal_documents.filesize'] = params[:filesize].to_i
      render :text => params[:filesize], :status => 200
    else
      render :nothing => true, :status => 200
    end
  end

end
class Admin::UrlsController < ApplicationController
  before_action :require_admin

  def index
    @recent_urls = Url.order(created_at: :desc)
  end

  def destroy
    @url = Url.find(params[:id])
    @url.destroy
    redirect_to admin_urls_path, notice: "URL eliminada"
  end

  private

  def require_admin
    redirect_to root_path, alert: "Acceso denegado" unless current_user&.admin?
  end
end
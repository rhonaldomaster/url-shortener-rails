class UrlsController < ApplicationController
  before_action :authenticate_user!, except: [:redirect]

  def index
    @url = Url.new
    @recent_urls = current_user ? current_user.urls.order(created_at: :desc).limit(10) : Url.order(created_at: :desc).limit(10)
  end

  def create
    @url = current_user.urls.build(url_params)

    if @url.save
      redirect_to root_path, notice: "URL acortada: #{short_url(@url)}"
    else
      @recent_urls = current_user ? current_user.urls.order(created_at: :desc).limit(10) : Url.order(created_at: :desc).limit(10)
      render :index, status: :unprocessable_entity
    end
  end

  def redirect
    @url = Url.find_by!(short_code: params[:short_code])
    if @url.expired?
      redirect_to root_path, alert: "Esta URL ha expirado"
      return
    end

    @url.clicks.create(ip_address: request.remote_ip, referrer: request.referrer, user_agent: request.user_agent)
    redirect_to @url.original_url, allow_other_host: true
  end

  private

  def url_params
    params.require(:url).permit(:original_url, :short_code, :expires_at)
  end

  def short_url(url)
    "#{request.base_url}/#{url.short_code}"
  end
  helper_method :short_url
end

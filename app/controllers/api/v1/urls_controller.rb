class Api::V1::UrlsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def index
    @urls = Url.order(created_at: :desc).limit(10)
    render json: @urls
  end

  def show
    @url = Url.find_by!(short_code: params[:id])
    render json: {
      url: @url,
      stats: {
        totalClicks: @url.clicks.count,
        clicksPerDay: @url.clicks.group("DATE(created_at)").count,
        topReferrers: @url.clicks.group(:referrer).order("count_all DESC").limit(5).count
      }
    }
  end

  def create
    @url = Url.new(url_params)
    if @url.save
      render json: { message: "Url creada" }, status: :created
    else
      render json: { errors: @url.errors }, status: :unprocessable_entity
    end
  end

  private

  def url_params
    params.require(:url).permit(:original_url, :short_code, :expires_at)
  end
end
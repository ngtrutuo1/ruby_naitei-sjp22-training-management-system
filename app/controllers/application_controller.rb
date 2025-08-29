class ApplicationController < ActionController::Base
  include Pagy::Backend
  include UserLoadable

  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :authenticate_user!
  before_action :store_user_location

  include CanCan::ControllerAdditions
  rescue_from CanCan::AccessDenied, with: :user_not_authorized

  protected

  attr_accessor :page_class

  private

  def set_locale
    locale = params[:locale]
    allowed_locales = I18n.available_locales.map(&:to_s)
    I18n.locale = if locale && allowed_locales.include?(locale)
                    locale
                  else
                    session[:locale] || I18n.default_locale
                  end
    session[:locale] = I18n.locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def correct_user
    return if current_user.admin?

    return if current_user == @user

    flash[:danger] = t("shared.not_authorized")
    redirect_to root_path
  end

  def manager?
    return false unless current_user

    current_user&.admin? || current_user&.supervisor?
  end

  def require_manager
    return if manager?

    flash[:danger] = t("messages.permission_denied")
    redirect_to root_path
  end

  def store_user_location
    return unless request.get?
    return if request.xhr? # Skip AJAX requests

    session[:forwarding_url] = request.fullpath
  end

  def user_not_authorized _exception
    flash[:danger] = t("shared.not_authorized")
    redirect_to(request.referer || root_path)
  end
end

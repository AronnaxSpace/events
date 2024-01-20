class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :check_profile
  before_action :set_time_zone

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout :layout_by_resource

  private

  def check_profile
    return unless user_signed_in?
    return if current_user.profile.present?
    return if controller_name == 'profiles' && action_name.in?(%w[new create])

    redirect_to new_profile_path
  end

  def set_time_zone
    return unless user_signed_in?
    return unless current_user.profile.present?

    Time.zone = current_user.time_zone
  end

  def user_not_authorized
    flash[:alert] = t('not_authorized')
    redirect_back(fallback_location: root_path)
  end

  def layout_by_resource
    return 'public' if devise_controller? || controller_name == 'welcome'

    'application'
  end
end

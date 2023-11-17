class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :check_profile

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def check_profile
    return unless user_signed_in?
    return if current_user.profile.present?
    return if controller_name == 'profiles' && action_name.in?(%w[new create])

    redirect_to new_profile_path
  end

  def user_not_authorized
    flash[:alert] = t('not_authorized')
    redirect_back(fallback_location: root_path)
  end
end

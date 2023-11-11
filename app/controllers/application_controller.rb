class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :check_profile

  private

  def check_profile
    return unless user_signed_in?
    return if current_user.profile.present?
    return if controller_name == 'profiles' && action_name.in?(%w[new create])

    redirect_to new_profile_path
  end
end

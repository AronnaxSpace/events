class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index about]
  before_action :redirect_to_authenticated_root, only: %i[index], if: :user_signed_in?

  private

  def redirect_to_authenticated_root
    redirect_to authenticated_root_path
  end
end

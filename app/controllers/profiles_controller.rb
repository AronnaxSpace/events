class ProfilesController < ApplicationController
  before_action :check_profile, only: %i[new create]

  helper_method :profile

  def new
    @profile = Profile.new
  end

  def edit; end

  def create
    @profile = current_user.build_profile(profile_params)

    if @profile.save
      redirect_to root_path, notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if profile.update(profile_params)
      redirect_to root_path, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def check_profile
    redirect_to edit_profile_path if profile.present?
  end

  def profile
    @profile ||= current_user.profile
  end

  def profile_params
    params.require(:profile).permit(
      :name, :nickname
    )
  end
end

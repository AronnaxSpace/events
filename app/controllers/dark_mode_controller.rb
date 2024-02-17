class DarkModeController < ApplicationController
  def toggle
    cookies[:dark_mode] = cookies[:dark_mode] == 'on' ? 'off' : 'on'

    redirect_to root_path
  end
end

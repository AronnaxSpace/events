class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index about]
end

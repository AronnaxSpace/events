class PeopleController < ApplicationController
  def index
    @people = User.without(current_user).with_profile
  end
end

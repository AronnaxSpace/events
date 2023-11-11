module ApplicationHelper
  def show_bottom_navbar?
    user_signed_in? && current_user.profile&.persisted?
  end
end

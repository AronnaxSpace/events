module BottomNavbarHelper
  def show_bottom_navbar?
    user_signed_in? && current_user.profile&.persisted?
  end

  def show_new_offer_button_in_bottom_navbar?
    !new_offer_page?
  end
end

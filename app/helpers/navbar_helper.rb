module NavbarHelper
  def show_top_navbar?
    friends_page? || incoming_friend_requests_page? || people_page?
  end

  def show_bottom_navbar?
    user_signed_in? && current_user.profile&.persisted?
  end

  def show_new_offer_button_in_bottom_navbar?
    !new_offer_page?
  end
end

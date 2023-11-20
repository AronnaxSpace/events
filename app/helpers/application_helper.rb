module ApplicationHelper
  def available_interface_languages_for_select
    [
      %w[English en],
      %w[Українська uk]
    ]
  end

  def offer_page?
    controller_name == 'offers' && action_name == 'show'
  end

  def offers_page?
    controller_name == 'offers' && action_name == 'index'
  end

  def new_offer_page?
    controller_name == 'offers' && %i[new create].include?(action_name.to_sym)
  end

  def edit_offer_page?
    controller_name == 'offers' && %i[edit update].include?(action_name.to_sym)
  end

  def offer_bulk_add_invitations_page?
    controller_name == 'offer_invitations' && %i[bulk_add bulk_create].include?(action_name.to_sym)
  end
end

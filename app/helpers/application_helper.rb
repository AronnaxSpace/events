module ApplicationHelper
  def available_interface_languages_for_select
    [
      %w[English en],
      %w[Українська uk]
    ]
  end

  def dark_mode_on?
    cookies[:dark_mode] == 'on'
  end

  def about_page?
    controller_name == 'welcome' && action_name == 'about'
  end

  def event_page?
    controller_name == 'events' && action_name == 'show'
  end

  def events_page?
    controller_name == 'events' && action_name == 'index'
  end

  def new_event_page?
    controller_name == 'events' && %i[new create].include?(action_name.to_sym)
  end

  def edit_event_page?
    controller_name == 'events' && %i[edit update].include?(action_name.to_sym)
  end

  def event_bulk_add_invitations_page?
    controller_name == 'event_invitations' && %i[bulk_add bulk_create].include?(action_name.to_sym)
  end

  def friends_page?
    controller_name == 'friends' && action_name == 'index' && !%i[incoming outgoing].include?(params[:scope]&.to_sym)
  end

  def incoming_friend_requests_page?
    controller_name == 'friends' && action_name == 'index' && params[:scope] == 'incoming'
  end

  def people_page?
    controller_name == 'people' && action_name == 'index'
  end
end

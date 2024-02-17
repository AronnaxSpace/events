class EventMailer < ApplicationMailer
  def new_event
    @event_invitation = params[:event_invitation]
    @event = @event_invitation.event
    @user = @event_invitation.user

    mail(to: @user.email, subject: 'New event')
  end
end

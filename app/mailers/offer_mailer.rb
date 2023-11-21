class OfferMailer < ApplicationMailer
  def new_offer
    @offer_invitation = params[:offer_invitation]
    @offer = @offer_invitation.offer
    @user = @offer_invitation.user

    mail(to: @user.email, subject: 'New offer')
  end
end

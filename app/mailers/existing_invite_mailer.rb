class ExistingInviteMailer < ApplicationMailer
  def existing_invite_mailer(invite)
    @invite = invite
    @sender_email = @invite.sender.email
    @receiver_email = @invite.email
    mail( :to => @receiver_email, :from => @sender_email,
      :subject => "You've been added to a shared movie list." )
  end
end

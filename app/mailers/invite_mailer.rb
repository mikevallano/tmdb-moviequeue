class InviteMailer < ApplicationMailer
  def new_invite_mailer(invite)
    @invite = invite
    @sender_email = @invite.sender.email
    @receiver_email = @invite.email
    mail( :to => @receiver_email, :reply_to => @sender_email,
      :subject => "Movies are better watched together." )
  end
end

class InviteMailer < ApplicationMailer
  def new_invite_mailer(invite)
    @invite = invite
    @sender_email = @invite.sender.email
    @sender_name = @invite.sender.username
    @receiver_email = @invite.email
    mail( :to => @receiver_email, :reply_to => @sender_email,
      :from => email_address_with_name(default_params[:from], "#{@sender_name} via Flicks On Lists"),
      :subject => "Movies are better watched together." )
  end
end

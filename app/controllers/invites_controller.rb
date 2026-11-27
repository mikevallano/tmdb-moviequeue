class InvitesController < ApplicationController
  before_action :authenticate_user!

  def create
    @invite = Invite.new(invite_params)
    @invite.email = @invite.email.strip if @invite.email.present?
    @invite[:token] = @invite.generate_token
    @invitee = @invite.find_invitee

    if @invite.save
      if @invite.to_existing_user?
        #round out the invites
        @invitee.memberships << Membership.new(member_id: @invitee.id, list_id: @invite.list_id)
        @invite.sender.memberships << Membership.new(member_id: @invite.sender_id, list_id: @invite.list_id)
        ExistingInviteMailer.existing_invite_mailer(@invite).deliver_now
      else
        InviteMailer.new_invite_mailer(@invite).deliver_now
        #assign the sender the membership as well
        @invite.sender.memberships << Membership.new(member_id: @invite.sender_id, list_id: @invite.list_id)
      end
      redirect_to user_list_path(@invite.sender, @invite.list), notice: 'Invite was sent.'
    else
      redirect_to user_list_path(@invite.sender, @invite.list), notice: 'Enter a valid email.'
    end
  end #create

 private

  def invite_params
    params.require(:invite).permit(:sender_id, :receiver_id, :token, :email, :list_id)
  end

end

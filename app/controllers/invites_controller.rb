class InvitesController < ApplicationController
  before_action :authenticate_user!

  def create
    @invite = Invite.new(invite_params)
    @invite[:token] = @invite.generate_token
    @invitee = @invite.find_invitee

    if @invite.to_existing_user?
        respond_to do |format|
        if @invite.save
          #round out the invites TODO: add these methods to user.rb instead:
          @invitee.memberships << Membership.new(member_id: @invitee.id, list_id: @invite.list_id)
          @invite.sender.memberships << Membership.new(member_id: @invite.sender_id, list_id: @invite.list_id)
          ExistingInviteMailer.existing_invite_mailer(@invite).deliver_now

          format.html { redirect_to list_path(@invite.list), notice: 'Invite was sent.' }
        else
          format.html { redirect_to list_path(@invite.list), notice: 'Enter a valid email.' }
          format.json { render json: @invite.errors, status: :unprocessable_entity }
        end
      end #end respond_to

    else #exising user?

      respond_to do |format|
        if @invite.save
          InviteMailer.new_invite_mailer(@invite).deliver_now
          #assign the sender the membership as well, TODO: move logic to user.rb
          @invite.sender.memberships << Membership.new(member_id: @invite.sender_id, list_id: @invite.list_id)
          format.html { redirect_to list_path(@invite.list), notice: 'Invite was sent.' }
          format.json { render :show, status: :created, location: @invite }
        else
          format.html { redirect_to list_path(@invite.list), notice: 'Enter a valid email.' }
          format.json { render json: @invite.errors, status: :unprocessable_entity }
        end
      end
    end #determining existing user
  end #create

 private

  def invite_params
    params.require(:invite).permit(:sender_id, :receiver_id, :token, :email, :list_id)
  end

end
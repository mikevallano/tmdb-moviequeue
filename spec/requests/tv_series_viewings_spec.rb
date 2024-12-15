require "rails_helper"

RSpec.describe TVSeriesViewingsController, type: :request do
  context "when the user is not authenticated" do
    let(:tv_series_viewing) { create(:tv_series_viewing) }
    let(:user) { tv_series_viewing.user }

    it "GET #index redirects to the sign-in path" do
      get tv_series_viewings_path
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end

    it "GET #edit redirects to the sign-in path" do
      get edit_tv_series_viewing_path(tv_series_viewing)
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end

    it "POST #create redirects to the sign-in path" do
      post tv_series_viewings_path(title: "foo", show_id: "123", url: "foo/", started_at: Time.current)
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end

    it "PATCH #update redirects to the sign-in path" do
      # patch tv_series_viewing_path(id: tv_series_viewing.id, params: { ended_at: Time.current} )
      patch tv_series_viewing_path(tv_series_viewing.id, params: { ended_at: Time.current} )
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end

    it "DELETE #destroy redirects to the sign-in path" do
      delete tv_series_viewing_path(tv_series_viewing)
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end
  end

  context "when the user is authenticated" do
    let(:tv_series_viewing) { create(:tv_series_viewing) }
    let(:user) { tv_series_viewing.user }

    before do
      # sign_in(user)
      allow_any_instance_of(TVSeriesViewingsController).to receive(:authenticate_user!).and_return(true)
      allow_any_instance_of(TVSeriesViewingsController).to receive(:current_user).and_return(user)
    end

    describe "GET #index" do
      it "is successful" do
        get tv_series_viewings_path
        expect(response).to be_successful
      end
    end

    describe "GET #edit" do
      it "is successful" do
        get edit_tv_series_viewing_path(tv_series_viewing)
        expect(response).to be_successful
      end
    end

    describe "POST #create" do
      let(:valid_params) { build(:tv_series_viewing).attributes}
      
      context "when it is a turbo request" do
        let(:turbo_request) { post tv_series_viewings_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" } }
        
        it "successfully renders a turbo response" do
          turbo_request
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq Mime[:turbo_stream]
        end

        it "renders the create template" do
          turbo_request
          expect(response).to render_template('tv_series_viewings/create')
        end

        it "creates a record" do
          expect {
            turbo_request
          }.to change(TVSeriesViewing, :count)
        end
      end

      context "when it is a rest request" do
        let(:rest_request) { post tv_series_viewings_path, params: valid_params}

        it "creates a record" do
          expect {
            rest_request
          }.to change(TVSeriesViewing, :count)
        end

        it "redirects to the series page" do
          rest_request
          expect(response).to be_redirect
          expect(response).to redirect_to tv_series_path(show_id: valid_params['show_id'])
        end 
        
      end
    end

    describe "PATCH #update" do
      let(:tv_series_viewing) { create(:tv_series_viewing, title: original_title) }
      let(:original_title) {"Original Title" }
      let(:changed_title) {"Changed Title" }

      context "when it is a turbo request" do
        let(:turbo_request) { patch tv_series_viewing_path(id: tv_series_viewing.id, format: :turbo_stream, params: {tv_series_viewing: {title: changed_title}}) }
        
        it "successfully renders a turbo response" do
          turbo_request
          expect(response).to have_http_status(:ok)

        end  
        
        it "updates the record" do
          turbo_request
          expect(tv_series_viewing.reload.title).to eq(changed_title)
        end
      end
      
      context "when it is a rest request" do
        let(:rest_request) { patch tv_series_viewing_path(tv_series_viewing, data: {turbo: false}, params: {tv_series_viewing: {title: changed_title}}) }

        it "updates the record" do
          rest_request
          expect(tv_series_viewing.reload.title).to eq(changed_title)
        end 

        it "redirects to the index page" do
          rest_request
          expect(response).to be_redirect
          expect(response).to redirect_to tv_series_viewings_path
        end 
      end
    end

    describe "DELETE #destroy" do
      let(:tv_series_viewing) { create(:tv_series_viewing) }

      it "destroys the record" do
        expect {
          delete tv_series_viewing_path(tv_series_viewing)
        }.to change(TVSeriesViewing, :count)
      end

      it "is redirects to tv_series_viewings_url" do
        delete tv_series_viewing_path(tv_series_viewing)
        expect(response).to be_redirect
        expect(response).to redirect_to tv_series_viewings_url
      end
    end




    # chatgpt
    # let(:tv_series_viewing) { build(:tv_series_viewing) }
    # let(:valid_params) { { tv_series_viewing: tv_series_viewing.attributes } }
    # let(:user) { tv_series_viewing.user }
    # describe 'POST #create' do
    #   context 'when the request is made with Turbo' do
    #     it 'responds with a Turbo Stream' do
    #       post tv_series_viewings_path, params: valid_params, headers: { 'Turbo-Frame' => 'true' }

    #       expect(response).to have_http_status(:ok)
    #       expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    #       expect(response.body).to include('<turbo-stream') # Ensure it includes Turbo stream content
    #     end

    #     it 'creates a new TVSeriesViewing' do
    #       expect {
    #         post tv_series_viewings_path, params: valid_params, headers: { 'Turbo-Frame' => 'true' }
    #       }.to change(TVSeriesViewing, :count).by(1)
    #     end
    #   end

    #   context 'when the request is made as REST' do
    #     it 'redirects to the index page' do
    #       post tv_series_viewings_path, params: valid_params

    #       expect(response).to have_http_status(:found)
    #       expect(response).to redirect_to(tv_series_viewings_path)
    #     end

    #     it 'creates a new TVSeriesViewing' do
    #       expect {
    #         post tv_series_viewings_path, params: valid_params
    #       }.to change(TVSeriesViewing, :count).by(1)
    #     end
    #   end
    # end

  end
end
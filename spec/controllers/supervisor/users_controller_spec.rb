require "rails_helper"

RSpec.describe Supervisor::UsersController, type: :controller do
  let!(:supervisor) { create(:user, :supervisor) }
  let!(:trainee_active) { create(:user, :trainee, activated: true) }
  let!(:trainee_inactive) { create(:user, :trainee, activated: false) }
  let(:default_locale) { I18n.default_locale }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects to the login page" do
        get :index, params: { locale: default_locale }
        expect(response).to redirect_to(login_path(locale: default_locale))
      end
    end

    context "when logged in as a non-supervisor (trainee)" do
      before do
        # Trực tiếp stub authentication cho user là trainee
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(trainee_active)
      end
      
      it "redirects to the root path" do
        get :index, params: { locale: default_locale }
        expect(response).to redirect_to(root_path(locale: default_locale))
      end
    end

    context "when logged in as a supervisor" do
      before do
        # Trực tiếp stub authentication cho user là supervisor
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
        get :index, params: { locale: default_locale }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end

      it "assigns the correct trainees" do
        expect(assigns(:trainees)).to include(trainee_active, trainee_inactive)
      end
    end
  end

  describe "GET #show" do
    context "when logged in as a supervisor" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      context "with a valid trainee ID" do
        before { get :show, params: { id: trainee_active.id, locale: default_locale } }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "assigns the correct trainee" do
          expect(assigns(:user_trainee)).to eq(trainee_active)
        end
      end

      context "with an invalid trainee ID" do
        before { get :show, params: { id: 9999, locale: default_locale } }

        it "redirects to the index page" do
          expect(response).to redirect_to(supervisor_users_path(locale: default_locale))
        end
      end
    end
  end

  describe "PATCH #update" do
    context "when logged in as a supervisor" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      context "with valid parameters" do
        let(:update_params) { { user: { name: "Updated Name" } } }
        before { patch :update, params: { id: trainee_active.id, **update_params, locale: default_locale } }

        it "updates the trainee's name" do
          expect(trainee_active.reload.name).to eq("Updated Name")
        end

        it "redirects to the trainee's show page" do
          expect(response).to redirect_to(supervisor_user_path(trainee_active, locale: default_locale))
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) { { user: { name: "" } } }
        before { patch :update, params: { id: trainee_active.id, **invalid_params, locale: default_locale } }

        it "does not update the trainee" do
          expect(trainee_active.reload.name).not_to eq("")
        end

        it "re-renders the show page" do
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe "PATCH #update_status" do
    context "when logged in as a supervisor" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      it "activates a deactivated user" do
        patch :update_status, params: { id: trainee_inactive.id, activated: true, locale: default_locale }
        expect(trainee_inactive.reload.activated?).to be true
      end

      it "deactivates an activated user" do
        patch :update_status, params: { id: trainee_active.id, activated: false, locale: default_locale }
        expect(trainee_active.reload.activated?).to be false
      end
    end
  end

  describe "PATCH #bulk_deactivate" do
    context "when logged in as a supervisor" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      context "with selected trainee_ids" do
        before { patch :bulk_deactivate, params: { trainee_ids: [trainee_active.id, trainee_inactive.id], locale: default_locale } }

        it "deactivates the active trainee" do
          expect(trainee_active.reload.activated?).to be false
        end

        it "activates the inactive trainee" do
          expect(trainee_inactive.reload.activated?).to be true
        end
      end

      context "with no trainees selected" do
        it "redirects to the index page" do
          patch :bulk_deactivate, params: { trainee_ids: [], locale: default_locale }
          expect(response).to redirect_to(supervisor_users_path(locale: default_locale))
        end
      end
    end
  end
end

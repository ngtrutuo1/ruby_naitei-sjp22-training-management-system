# spec/support/shared_examples/authorization_examples.rb

RSpec.shared_examples "requires login" do |http_method, action, params = {}|
  # Use a let block to define the params for the request. This is more robust.
  let(:request_params) { params }

  context "when not logged in" do
    it "redirects to the login page" do
      public_send(http_method, action, params: request_params)
      # Now we can safely access the locale from the let block.
      expect(response).to redirect_to(login_path(locale: request_params[:locale]))
    end
  end
end

RSpec.shared_examples "requires admin role" do |http_method, action, params = {}|
  let(:non_admin) { create(:user, :supervisor) }
  let(:request_params) { params }

  context "when logged in as a non-admin" do
    before { sign_in(non_admin) }
    it "redirects to the root path" do
      public_send(http_method, action, params: request_params)
      expect(response).to redirect_to(root_path(locale: request_params[:locale]))
    end
  end

  include_examples "requires login", http_method, action, params
end

RSpec.shared_examples "requires supervisor role" do |http_method, action, params = {}|
  let(:non_supervisor) { create(:user, :trainee) }
  let(:request_params) { params }

  context "when logged in as a non-supervisor" do
    before { sign_in(non_supervisor) }
    it "redirects to the root path" do
      public_send(http_method, action, params: request_params)
      expect(response).to redirect_to(root_path(locale: request_params[:locale]))
    end
  end

  include_examples "requires login", http_method, action, params
end

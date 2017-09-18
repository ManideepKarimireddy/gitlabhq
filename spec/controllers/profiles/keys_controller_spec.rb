require 'spec_helper'

describe Profiles::KeysController do
  let(:user) { create(:user) }

  describe "#get_keys" do
    describe "non existant user" do
      it "does not generally work" do
        get :get_keys, username: 'not-existent'

        expect(response).not_to be_success
      end
    end

    describe "user with no keys" do
      it "does generally work" do
        get :get_keys, username: user.username

        expect(response).to be_success
      end

      it "renders all keys separated with a new line" do
        get :get_keys, username: user.username

        expect(response.body).to eq("")
      end

      it "responds with text/plain content type" do
        get :get_keys, username: user.username
        expect(response.content_type).to eq("text/plain")
      end
    end

    describe "user with keys" do
      let!(:key) { create(:key, user: user) }
      let!(:another_key) { create(:another_key, user: user) }
      let!(:deploy_key) { create(:deploy_key, user: user) }

      it "does generally work" do
        get :get_keys, username: user.username

        expect(response).to be_success
      end

      it "renders all non deploy keys separated with a new line" do
        get :get_keys, username: user.username

        expect(response.body).not_to eq('')
        expect(response.body).to eq(user.all_ssh_keys.join("\n"))

        expect(response.body).to include(key.key.sub(' dummy@gitlab.com', ''))
        expect(response.body).to include(another_key.key.sub(' dummy@gitlab.com', ''))

        expect(response.body).not_to include(deploy_key.key)
      end

      it "does not render the comment of the key" do
        get :get_keys, username: user.username

        expect(response.body).not_to match(/dummy@gitlab.com/)
      end

      it "responds with text/plain content type" do
        get :get_keys, username: user.username
        expect(response.content_type).to eq("text/plain")
      end
    end
  end

  describe '#create' do
    it 'logs the audit event' do
      sign_in(user)

      key = build(:key)
      
      expect { post :create, key: key.attributes }.to change{ SecurityEvent.count }.by(1)
    end
  end
end

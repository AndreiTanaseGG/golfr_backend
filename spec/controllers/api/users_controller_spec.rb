require 'rails_helper'

describe Api::UsersController, type: :controller do
  describe 'POST login' do
    before :each do
      create(:user, email: 'user@email.com', password: 'userpass')
    end

    it 'should return the token if valid username/password' do
      post :login, params: { email: 'user@email.com', password: 'userpass' }

      expect(response).to have_http_status(:ok)
      response_hash = JSON.parse(response.body)
      user_data = response_hash['user']

      expect(user_data['token']).to be_present
    end

    it 'should return an error if invalid username/password' do
      post :login, params: { email: 'invalid', password: 'user' }

      expect(response).to have_http_status(401)
    end
  end

  describe 'GET feed' do
    before :each do
      @user1 = create(:user, name: 'User1', email: 'user1@email.com', password: 'userpass')
      user2 = create(:user, name: 'User2', email: 'user2@email.com', password: 'userpass')
      sign_in(@user1, scope: :user)

      @score1 = create(:score, user: @user1, total_score: 79, played_at: '2021-05-20')
      @score2 = create(:score, user: @user1, total_score: 81, played_at: '2021-05-19')
      @score3 = create(:score, user: user2, total_score: 99, played_at: '2021-06-20')
    end

    it 'should return the scores of User1' do
      get :user_scores, params: { id: @user1.id }

      expect(response).to have_http_status(:ok)
      response_hash = JSON.parse(response.body)
      user_name = response_hash['user']['name']
      scores = response_hash['user']['scores']

      expect(scores.size).to eq 2
      expect(user_name).to eq 'User1'
      expect(scores[0]['total_score']).to eq 79
      expect(scores[0]['played_at']).to eq '2021-05-20'
      expect(scores[1]['total_score']).to eq 81
    end
  end
end

require "heroku/client"

class Heroku::Client::Notifications
  include Heroku::Helpers

  def initialize(user_email, password)
    @user_email = user_email
    @password   = password
  end

  def get_notifications
    response = notifications_resource["/api/v1/notifications"].get
    json_decode(response.to_s)
  end

  def read_notification(id)
    response = notifications_resource["/api/v1/notifications/#{id}/read"].post ''
    response.code == 200
  end

private
  def notifications_resource
    RestClient::Resource.new(
      "https://keikoku.herokuapp.com",
      :user     => @user_email,
      :password => @password
    )
  end
end

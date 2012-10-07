require 'spec_helper'
require "heroku/client/notifications"

describe Heroku::Client::Notifications, '#get_notifications' do
  include Heroku::Helpers

  before do
    Heroku::Auth.stub :user => 'user@example.com', :password => 'apitoken'
  end

  it 'finds notifications for a user' do
    response_fixture = [
          {
            'resource' => 'flying-monkey-123',
            'message'  => 'Database HEROKU_POSTGRESQL_BROWN is over row limits',
            'url'      => 'https://devcenter.heroku.com/how-to-fix-problem',
            'severity' => 'info'
          },
          {
            'resource' => 'rising-cloud-42',
            'message'  => 'High OOM rates',
            'url'      => 'https://devcenter.heroku.com/oom',
            'severity' => 'fatal'
          }
        ]
    url = "https://user@example.com:apitoken@keikoku.herokuapp.com/api/v1/notifications"
    stub_request(:get, url).to_return(
      body:   json_encode(response_fixture),
      status: 200
    )

    notifications = Heroku::Client::Notifications.new('user@example.com').
      get_notifications
    notifications.should == response_fixture
  end

  it "marks a notification as read" do
    url = "https://user%40example.com:apitoken@keikoku.herokuapp.com/api/v1/notifications/1/read"

    stub_request(:post, url).to_return(status: 200)

    result = Heroku::Client::Notifications.new('user@example.com').read_notification(1)
    result.should be_true
  end
end

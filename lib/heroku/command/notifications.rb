require 'heroku/client/notifications'
require "heroku/command/base"

class Heroku::Command::Notifications < Heroku::Command::Base

  # notifications
  #
  # Show all notifications
  def index
    notifications = notifications_client.get_notifications
    if notifications.empty?
      display("#{current_user} has no notifications.")
    else
      display_header("Notifications for #{current_user} (#{notifications.count})", true)
      display(notifications.map do |notification|
        out = "#{notification['account_sequence']}: #{notification['target_name']}\n"
        out += "  [#{notification['severity']}] #{notification['message']}\n"
        out += "  More info: #{notification['url']}\n"
        out
      end.join("\n"))
      notifications.each do |notification|
        notifications_client.read_notification(notification['id'])
      end
    end
  end

private
  def notifications_client
    Heroku::Client::Notifications.new(Heroku::Auth.user, Heroku::Auth.password)
  end

  def current_user
    Heroku::Auth.user
  end
end

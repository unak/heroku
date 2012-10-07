require "spec_helper"
require "heroku/command/notifications"


module Heroku::Command
  describe Notifications do

    before(:each) do
      stub_core
      api.post_app("name" => "myapp", "stack" => "cedar")
    end

    after(:each) do
      api.delete_app("myapp")
    end

    it "shows an empty list when no notifications available" do
      stub_notifications.get_notifications.returns([])
      stderr, stdout = execute("notifications")
      stderr.should == ""
      stdout.should =~ /has no notifications/
    end

    it "shows notifications if they exist" do
      stub_user_notifications!
      stderr, stdout = execute("notifications")
      stderr.should == ""
      stdout.should == (<<-END_STDOUT)
=== Notifications for email@example.com (2)
n30: flying-monkey-123
  [info] Database HEROKU_POSTGRESQL_BROWN is over row limits
  More info: https://devcenter.heroku.com/how-to-fix-problem

n31: rising-cloud-42
  [fatal] High OOM rates
  More info: https://devcenter.heroku.com/oom
END_STDOUT
    end

    it "marks notifications as read" do
      stub_user_notifications!
      stub_notifications.read_notification(1).returns(true)


      stderr, stdout = execute("notifications:read n30")
      stderr.should == ""
      stdout.should == (<<-END_STDOUT)
Marked n30 as read
END_STDOUT
    end

    it "marks all notifications as read if no args passed" do
      stub_user_notifications!
      stub_notifications.read_notification(1).returns(true)
      stub_notifications.read_notification(2).returns(true)

      stderr, stdout = execute("notifications:read")
      stdout.should == (<<-END_STDOUT)
Marked n30 as read
Marked n31 as read
END_STDOUT
    end

    def stub_user_notifications!
      stub_notifications.get_notifications.returns(
        [
          {
            'id'               => 1,
            'account_sequence' => 'n30',
            'target_name'      => 'flying-monkey-123',
            'message'          => 'Database HEROKU_POSTGRESQL_BROWN is over row limits',
            'url'              => 'https://devcenter.heroku.com/how-to-fix-problem',
            'severity'         => 'info'
          },
          {
            'id'               => 2,
            'account_sequence' => 'n31',
            'target_name'      => 'rising-cloud-42',
            'message'          => 'High OOM rates',
            'url'              => 'https://devcenter.heroku.com/oom',
            'severity'         => 'fatal'
          }
        ]
      )
    end
  end
end

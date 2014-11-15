module Heroku::Command
  class JSPlugins < Base
    def index
      Heroku::JSPlugin.setup
      Heroku::JSPlugin.plugins.each do |plugin|
        puts plugin
      end
    end
  end
end

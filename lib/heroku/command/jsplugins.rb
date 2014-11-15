module Heroku::Command
  class JSPlugins < Base
    def index
      setup
      run_heroku_plugins(ARGV[1..-1])
    end

    private

    def run_heroku_plugins(args)
      exec(heroku_plugins_path, *args)
    end

    def setup
      return if File.exist? heroku_plugins_path
      $stderr.print 'setting up heroku-plugins...'
      FileUtils.mkdir_p File.dirname(heroku_plugins_path)
      resp = Excon.get(url, middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::Decompress])
      open(heroku_plugins_path, "wb") do |file|
        file.write(resp.body)
      end
      File.chmod(0755, heroku_plugins_path)
      if Digest::SHA1.file(heroku_plugins_path).hexdigest != manifest['builds'][os][arch]['sha1']
        File.delete heroku_plugins_path
        raise 'SHA mismatch for heroku-plugins'
      end
      $stderr.puts 'done'
    end

    def heroku_plugins_path
      File.join(home_directory, ".heroku", "heroku-plugins")
    end

    def arch
      case RUBY_PLATFORM
      when /i386/
        "386"
      when /x64/
      else
        "amd64"
      end
    end

    def os
      case RUBY_PLATFORM
      when /darwin|mac os/
        "darwin"
      when /linux/
        "linux"
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        "windows"
      else
        raise "unsupported on #{RUBY_PLATFORM}"
      end
    end

    def manifest
      @manifest ||= JSON.parse(Excon.get("https://d1gvo455cekpjp.cloudfront.net/heroku-plugins/dev/manifest.json").body)
    end

    def url
      manifest['builds'][os][arch]['url'] + ".gz"
    end
  end
end

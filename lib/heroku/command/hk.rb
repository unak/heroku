module Heroku::Command
  class HK < Base
    def index
      setup
      run_hk(ARGV[1..-1])
    end

    private

    def run_hk(args)
      exec(hk_path, *args)
    end

    def setup
      return if File.exist? hk_path
      $stderr.print 'setting up hk...'
      FileUtils.mkdir_p File.dirname(hk_path)
      resp = Excon.get(url, middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::Decompress])
      open(hk_path, "wb") do |file|
        file.write(resp.body)
      end
      File.chmod(0755, hk_path)
      if Digest::SHA1.file(hk_path).hexdigest != manifest['builds'][os][arch]['sha1']
        File.delete hk_path
        raise 'SHA mismatch for hk'
      end
      $stderr.puts 'done'
    end

    def hk_path
      File.join(home_directory, ".heroku", "bin", "hk")
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
      @manifest ||= JSON.parse(Excon.get("https://d1gvo455cekpjp.cloudfront.net/hk/dev/manifest.json").body)
    end

    def url
      manifest['builds'][os][arch]['url'] + ".gz"
    end
  end
end

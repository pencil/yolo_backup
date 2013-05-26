module YOLOBackup
  class BackupRunner
    class Error < StandardError; end
    class UnknownServerError < Error; end

    OPTIONS = %w{servers verbose}

    OPTIONS.each do |option|
      attr_accessor option
    end
    alias_method :verbose?, :verbose

    def initialize(options)
      OPTIONS.each do |option|
        send("#{option}=", options[option]) if options[option]
      end
    end

    def backup(server = nil)
      if server.nil?
        servers.keys.each do |server|
          backup(server)
        end
      else
        raise UnknownServerError, "Server #{server} not defined" unless servers.key?(server)
        verbose_log(server)
      end
    end

    private
    def verbose_log(msg)
      puts "[BackupRunner] #{msg}" if verbose?
    end
  end
end

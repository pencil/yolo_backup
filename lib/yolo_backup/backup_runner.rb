require 'yolo_backup/backup_runner/job'
require 'yolo_backup/helper/log'

module YOLOBackup
  class BackupRunner
    include Helper::Log

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

    def backup(server_name = nil)
      if server_name.nil?
        servers.keys.each do |server_name|
          backup(server_name)
        end
      else
        raise UnknownServerError, "Server #{server_name} not defined" unless servers.key?(server_name)
        server = servers[server_name]
        log "Backup of #{server} requested" if verbose?
        job = Job.new 'server' => server, 'verbose' => verbose?
        job.start
      end
    end
  end
end

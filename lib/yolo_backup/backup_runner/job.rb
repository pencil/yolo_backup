require 'yolo_backup/helper/log'

module YOLOBackup
  class BackupRunner
    class Job
      include Helper::Log

      OPTIONS = %w{server verbose}

      OPTIONS.each do |option|
        attr_accessor option
      end

      alias_method :verbose?, :verbose

      def initialize(options)
        OPTIONS.each do |option|
          send("#{option}=", options[option]) if options[option]
        end
      end

      def start
        if backup_required?
        else
          log "Backup not required (latest backup = #{server.latest_backup})"
        end
      end

      def backup_required?
        false
      end
    end
  end
end

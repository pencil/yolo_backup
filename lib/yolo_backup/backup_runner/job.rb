require 'yolo_backup/helper/log'
require 'yolo_backup/backup_runner/backend/rsync'

module YOLOBackup
  class BackupRunner
    class Job
      include Helper::Log

      OPTIONS = %w{server verbose force}

      OPTIONS.each do |option|
        attr_accessor option
      end

      alias_method :verbose?, :verbose
      alias_method :force?, :force

      def initialize(options)
        OPTIONS.each do |option|
          send("#{option}=", options[option]) if options[option]
        end
      end

      def start
        if backup_required?
          p server.latest_backup
          log "Starting backup of #{server}"
          begin
            backend.start_backup
            log "Backup completed" if verbose?
            log "Cleaning up old backups" if verbose?
            log "Deleted #{server.cleanup_backups.length} backups" if verbose?
          rescue Backend::Error => e
            log "ERROR: #{e.message}"
          end
        else
          log "Backup not required (latest backup = #{server.latest_backup}, maximum backup age = #{maximum_backup_age})" if verbose?
        end
      end

      def backup_required?
        latest_backup = server.latest_backup
        return force? || latest_backup.nil? || latest_backup < maximum_backup_age
      end

      def maximum_backup_age
        case server.rotation.minimum_unit
        when 'hourly'
          1.hour.ago
        when 'daily'
          1.day.ago
        when 'weekly'
          1.week.ago
        when 'monthly'
          1.month.ago
        when 'yearly'
          1.year.ago
        end
      end

      def backend
        @backend ||= YOLOBackup::BackupRunner::Backend::Rsync.new(server)
      end
    end
  end
end

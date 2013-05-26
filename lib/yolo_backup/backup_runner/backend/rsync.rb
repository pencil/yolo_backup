require 'yolo_backup/backup_runner/backend'

class YOLOBackup::BackupRunner::Backend::Rsync < YOLOBackup::BackupRunner::Backend
  class RsyncFailedError < Error; end

  DEFAULT_RSYNC_OPTIONS = '-aAX --numeric-ids'

  attr_reader :server

  def initialize(server)
    @server = server
  end

  def start_backup
    server.storage.initiate_backup(server) do |path|
      options = [DEFAULT_RSYNC_OPTIONS]
      if server.latest_backup
        latest_backup = File.expand_path("#{path}/../#{server.latest_backup}")
        options << "--link-dest='#{latest_backup}'"
      end
      ssh_options = []
      ssh_options << "-i '#{server.ssh_key}'" unless server.ssh_key.nil?
      ssh_options << "-p '#{server.ssh_port}'" unless server.ssh_port.nil?
      options << "-e \"ssh #{ssh_options.join(' ')}\""
      options << "--exclude={#{server.excludes.join(',')}}"
      command = "rsync #{options.join(' ')} #{server.ssh_user || 'root'}@#{server.ssh_host || server}:/ '#{path}'"
      `#{command}`
      raise RsyncFailedError, "rsync command failed: #{$?}" unless $?.success?
    end
  end
end

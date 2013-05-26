require 'yolo_backup/backup_runner/backend'

class YOLOBackup::BackupRunner::Backend::Rsync < YOLOBackup::BackupRunner::Backend
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def start_backup
    server.storage.initiate_backup(server) do |path|
    end
  end
end

module YOLOBackup
  module Helper
    module Log
      def log(msg)
        puts "#{Time.now.iso8601} [#{self.class.name}] #{msg}"
      end
    end
  end
end

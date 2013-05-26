module YOLOBackup
  module Helper
    module Log
      def log(msg)
        puts "[#{self.class.name}] #{msg}"
      end
    end
  end
end

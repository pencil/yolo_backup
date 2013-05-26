module YOLOBackup
  class StoragePool
    attr_reader :name

    def initialize(name, options=nil)
      @name = name
    end
  end
end

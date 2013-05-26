module YOLOBackup
  class ExcludeSet
    attr_reader :name, :excludes

    def initialize(name, excludes)
      @name = name
      @excludes = excludes
    end

    def to_s
      "#{name} (#{excludes.join(', ')})"
    end
  end
end

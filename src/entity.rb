class Entity

    attr_reader :id

    def initialize(world, id, table=nil)
        @world = world
        @table = table
        @id = id
    end

    def exists?
        @table.exists? @id
    end

    def invalid?
        @table.exists?(@id) == false
    end

    def name
        @table.get(:name, @id)
    end

    def inspect
        h = {:id => @id}
        @table.props.each do |k|
            h[k] = @table.get(k, @id)
        end
        self.class.to_s + h.inspect
    end
end

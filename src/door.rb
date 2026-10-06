require 'entity'

class Door < Entity

    def initialize(world, id, table=nil)
        super world, id, world.doors
        @world = world
        @doors = world.doors
    end

    def open?
        not closed?
    end

    def closed?
        @doors.get(:closed, @id)
    end

end

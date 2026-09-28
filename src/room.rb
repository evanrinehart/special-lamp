require 'entity'

class Room < Entity
    def initialize(world, room_id, table=nil)
        super world, room_id, world.rooms
        @rooms = world.rooms
        @mobs = world.mobs
        @things = world.things
    end

    def mobs
        @mobs.find_by(:room_id, @id)
    end

    def things
        @things.find_by(:room_id, @id)
    end
end


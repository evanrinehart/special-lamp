require 'entity'

class Mob < Entity

    def initialize(world, mob_id, table=nil)
        super world, mob_id, world.mobs
        @mobs = world.mobs
        @things = world.things
        @rooms = world.rooms
        @powerbars = world.powerbars
    end

    def name
        @mobs.get(:name, @id)
    end

    def room
        room_id = @mobs.get(:room_id, @id)
        room_id && @rooms[room_id]
    end

    def things
        @things.find_by(:mob_id, @id)
    end

    def health
        health_id = @mobs.get(:health_id, @id)
        health_id && @powerbars[health_id]
    end

    def oxygen
        oxygen_id = @mobs.get(:oxygen_id, @id)
        oxygen_id && @powerbars[oxygen_id]
    end

    def move_to(room_id)
        @mobs.set(:room_id, @id, room_id)
    end

end

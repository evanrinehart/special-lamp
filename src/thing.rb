require 'entity'

class Thing < Entity

    def initialize(world, thing_id, table=nil)
        super world, thing_id, world.things
        @mobs = world.mobs
        @things = world.things
    end

    def move_to_mob(mob_id)
        @things.set(:mob_id, @id, mob_id)
        @things.set(:room_id, @id, nil)
    end

    def move_to_room(room_id)
        @things.set(:mob_id, @id, nil)
        @things.set(:room_id, @id, room_id)
    end

end

require 'entity'

class Device < Entity

    def initialize(world, id, table=nil)
        super world, id, world.devices
        @world = world
        @devices = world.devices
    end

    def host_object
        oid = @devices.get(:object_id, @id)
        Thing.new(@world, oid)
    end

    def quality
        @devices.get(:quality, @id)
    end

    def prototype
        @devices.get(:prototype, @id)
    end

    def enabled?
        @devices.get(:enabled, @id)
    end

    def energy
        @devices.get(:energy, @id)
    end

    def deduct_energy n
        lvl = self.energy
        @devices.set(:energy, @id, [lvl - n, 0].max)
    end

    def power_draw
        @devices.get(:power_draw, @id)
    end

end

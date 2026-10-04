require 'entity'

class Powerbar < Entity

    def initialize(world, powerbar_id, table=nil)
        super world, powerbar_id, world.powerbars
        @powerbars = world.powerbars
        @world = world
    end

    def value
        @powerbars.get(:value, @id)
    end

    def value_max
        @powerbars.get(:value_max, @id)
    end

    def set_value v
        @powerbars.get(:value, @id, v)
    end

    def percent
        value * 100 / value_max
    end

    def reduce_by dv
        v = self.value
        if dv > v
            set_value 0
        else
            set_value (v - dv)
        end
    end

end

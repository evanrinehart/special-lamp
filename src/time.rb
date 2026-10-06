require 'temperature'

class TimeDriver

    def initialize world, player
        @world = world
        @player = player
        @events = []
    end

    def get_events
        events = @events
        @events = []
        events
    end

    def put_event e
        @events.push e
    end

    def try_advance_seconds n
        count = 0
        n.times do
            stop = self.advance_second
            count += 1
            break if stop
        end
        count
    end

    def advance_second

        heat_driver = Heating.new @world

        deltas = heat_driver.heat_counter_deltas
        deltas.each do |entry|
            thing = Thing.new(@world, entry[:thing_id])
            heat_driver.apply_heat thing, entry[:delta], entry[:heating]
        end

        heat_driver.run_heaters

        @player.add_time 1
        nil
    end

end

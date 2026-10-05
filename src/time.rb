class TimeDriver

    def initialize world
        @world
        @events = []
    end

    def get_events
        events = @events
        @events = []
        events
    end

    def try_advance_seconds n
        count = 0
        n.times do
            stop = self.per_second_stuff
            count += 1
            break if stop
        end
        count
    end

    def per_second_stuff
        :stop
    end

end

require 'entity'

class Player < Entity

    def initialize(world, player_id, table=nil)
        super world, player_id, world.players
        @players = world.players
        @mobs = world.mobs
        @objects = world.objects
        @world = world
    end

    def mob_id
        @players.get(:mob_id, @id)
    end

    def mob
        Mob.new(@world, mob_id)
    end

    def clock
        @players.get(:clock, @id)
    end

    def add_time dn
        n = self.clock
        @players.set(:clock, @id, n + dn)
    end

    def day
        self.clock / 86400
    end

    def time_of_day
        self.clock % 86400
    end

    def show_time
        n = time_of_day
        hh = n / 3600
        mm = (n % 3600) / 60
        sprintf "%02d:%02d", hh, mm
    end

end

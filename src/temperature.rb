require 'world'
require 'device'
require 'thing'

class Heating

    def initialize world
        @world = world
        @things = world.objects
        @devices = world.devices
        @edges = world.edges
        @doors = world.doors
    end

    def heat_counter_deltas
        result = []
        @things.idlist.each do |thing_id|
            next if @things.get(:heat_counter, thing_id).nil?

            host = Thing.new(@world, thing_id)
            outside_temp = host.temperature
            inside_temp = host.inside_temperature

            next if outside_temp == inside_temp

            diff = (outside_temp - inside_temp).to_f
            sign = diff < 0.0 ? -1 : 1

            delta = 12345.0 * (diff.abs / 100.0)
            delta *= host.room_count
            delta /= (host.size.to_f / 10.0)
            delta *= 4.0 unless host.insulation?

            entry = {:thing_id => thing_id, :delta => delta.round, :heating => sign}
            result.push entry
        end
        result
    end

    def apply_heat thing, dcounter, delta_temp
        #puts "apply heat #{thing.id} c=#{thing.heat_counter} dc=#{dcounter}"
        c = thing.heat_counter

        if dcounter < c
            thing.set_heat_counter (c - dcounter)
        else
            thing.set_heat_counter ((c - dcounter) % 1000000)
            thing.heat_interior_by delta_temp
        end
    end

    def run_heaters
        heaters = @devices.find_by(:prototype, :heater).filter{|x| x.enabled}.map{|x| Device.new(@world, x.id)}
        heaters.each do |heater|
            host = heater.host_object
            next if host.inside_temperature >= 25
            puts "attempting to heat #{host.inspect} with heater"

            # todo heater requires available power to work

            host.heat_interior_by 1
        end
    end

end

# the temperature of a surface is by default determined by the
# surroundings of the object it is part of, if any.

# when a heating cycle is complete, the surface with the largest
# deviation from "target" is selected. And the interior surface
# temperature is adjusted according to a formula

# no. The heating cycle cooldown is determined by the temperature
# difference. At which time all inner surfaces are incremented
# or decremented. When the temperature equalizes, the heating
# cycle is suspended. If no insulation is present, then temperature
# of the interior inherits the surrounding temperature immediately.
# In a vacuum, you are awarded bonus insulation of high quality.

# heater device. This device continually increases the temperature
# each second by using power (per room, per size scale (4x previous)).
# until it reaches 25. During this time the heating cycle cooldown
# will be adjusted due to the changing temperature difference. At
# "equilibrium" the heater only runs after a heating cycle decrements
# the temperature. This determines equilibrium power usage.

# intercooler. This device will reduce the temperature of a complex
# if it is supplied with coolant. The coolant will degrade over time
# until cooling is disabled. If a heat pipe is available which goes
# to a working heat sink, the coolant won't degrade. Old coolant can
# be recycled at appropriate facilities.

# temperature in space. In a normal solar system, the surrounding
# temperature is determined by the sun and "altitude" (orbital distance).
# and might be high. Moving into a shadow sets the target temperature
# to the temperature of the shadowing object, which might be cold.

# heating cycle numerics
# the heating cycles's rate is determined by the temperature difference now.
# when the diff changes, the rate changes while the progress through the
# cycle doesn't. We do this by beginning with a counter of value 1,000,000.
# Each second subtract some integer determined by deltaT. When it reaches
# zero do a heating cycle update and reset counter to 1,000,000. So the
# slowest cycle time is a million seconds, quite slow. The rate is also
# reduced by insulation and increased by heatpipes.



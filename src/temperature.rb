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
            battery = host.devices.filter{|x| x.enabled? && x.prototype == :battery}.first

            next if battery.nil?
            next if host.inside_temperature >= 25

            need_energy = heater.power_draw || 0
            have_energy = battery.energy || 0
            next if need_energy > have_energy

            puts "attempting to heat #{host.inspect} with heater"
            puts "need_energy = #{need_energy}, have_energy = #{have_energy}"
            host.heat_interior_by 1
            battery.deduct_energy need_energy

        end
    end

end

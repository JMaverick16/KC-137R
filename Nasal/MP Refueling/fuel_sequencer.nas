# Copyright (C) 2015  onox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

var version = {
    major: 1,
    minor: 2
};

var AbstractTankPumpGroup = {

    new: func {
        var m = {
            parents:    [AbstractTankPumpGroup],
            tank_pumps: std.Vector.new(),
            condition: nil
        };
        return m;
    },

    set_condition: func (condition) {
        if (typeof(condition) != "func") {
            die("AbstractTankPumpGroup.set_condition: condition is not a function");
        }

        me.condition = condition;
    },

    add_tank_pump: func (tank, pump) {
        if (!isa(tank, fuel.Tank)) {
            die("TankPumpGroup.add_tank_pump: tank must be an instance of Tank");
        }
        if (!isa(pump, fuel.ServiceableFuelComponentMixin)) {
            die("TankPumpGroup.add_tank_pump: pump must be an instance of ServiceableFuelComponentMixin");
        }

        me.tank_pumps.append([tank, pump]);
    },

    update_pumps: func {
        die("AbstractTankPumpGroup.update_pumps is abstract");
    },

    disable_all_pumps: func {
        foreach (var tuple; me.tank_pumps.vector) {
            var pump = tuple[1];
            pump.disable();
        }
    }

};

var EmptyTankPumpGroup = {

    # Enables the corresponding pump of each tank that is not empty. If
    # a group has a non-empty tank, then the pumps of all lower priority
    # groups will be disabled.

    new: func (min_level) {
        var m = {
            parents:   [EmptyTankPumpGroup, AbstractTankPumpGroup.new()],
            min_level: min_level
        };
        return m;
    },

    update_pumps: func {
        var group_empty = 1;

        foreach (var tuple; me.tank_pumps.vector) {
            var tank = tuple[0];
            var pump = tuple[1];

            if (tank.get_current_level() > me.min_level) {
                group_empty = 0;
                pump.enable();
            }
            else {
                pump.disable();
            }
        }

        # Keep the group active if condition is met
        if (group_empty and me.condition != nil and me.condition(me)) {
            group_empty = 0;
        }

        return !group_empty;
    }

};

var FullTankPumpGroup = {

    # Enables the corresponding pump of each tank that is empty. If a
    # group has an empty tank, then the pumps of all lower priority
    # groups will be disabled.

    new: func (max_level) {
        var m = {
            parents:   [FullTankPumpGroup, AbstractTankPumpGroup.new()],
            max_level: max_level,
        };
        return m;
    },

    update_pumps: func {
        var group_empty = 1;

        foreach (var tuple; me.tank_pumps.vector) {
            var tank = tuple[0];
            var pump = tuple[1];

            if (tank.get_typical_level() - tank.get_current_level() > me.max_level) {
                group_empty = 0;
                pump.enable();
            }
            else {
                pump.disable();
            }
        }

        # Keep the group active if condition is met
        if (group_empty and me.condition != nil and me.condition(me)) {
            group_empty = 0;
        }

        return !group_empty;
    }

};

var PumpGroupSequencer = {

    # A PumpGroupSequencer iterates over groups of tanks enables/disables
    # the pumps depending on whether the corresponding tank is almost empty
    # or full. Exact behavior depends on the class that is given to the
    # new() constructor.
    #
    # Groups are created and added to the list by calling create_group(),
    # which returns an instance of TankPumpGroup. Call add_tank_pump()
    # on this object to add a tank and boost pump. The first group that
    # is created has the highest priority and the last group has the lowest
    # priority.

    new: func (min_level, pump_group_class) {
        var m = {
            parents:   [PumpGroupSequencer],
            groups:    std.Vector.new(),
            min_level: min_level,
            pump_group_class: pump_group_class
        };
        return m;
    },

    create_group: func {
        var group = me.pump_group_class.new(me.min_level);
        me.groups.append(group);
        return group;
    },

    update_pumps: func {
        var active = 0;

        foreach (var group; me.groups.vector) {
            # If no group is active yet, we check if the current group
            # has become active
            if (!active) {
                active = group.update_pumps();
            }
            # Once a group is active, all remaining groups must be disabled
            else {
                group.disable_all_pumps();
            }
        }
    }

};

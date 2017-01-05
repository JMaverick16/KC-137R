# Copyright (C) 2014 - 2015  onox
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
    major: 5,
    minor: 1
};

var min = std.min;
var max = std.max;

# Initialize debug property
var show_debug = props.globals.initNode("/systems/fuel/debug", 0, "BOOL");

var FuelComponent = {

    new: func (name) {
        var m = {
            parents: [FuelComponent],
            name:    name,
            node:    props.globals.initNode("/systems/fuel/" ~ name),
            current_gal_us: 0.0
        };

        m.node.setValues({
            "current-flow-gal_us-ps":  0.0,
        });

        return m;
    },

    get_param: func (param) {
        return me.node.getChild(param).getValue();
    },

    set_param: func (param, value) {
        me.node.getChild(param).setValue(value);
    },

    get_name: func {
        return me.name;
    },

    set_source: func (source) {
        if (!isa(source, FuelComponent)) {
            die("FuelComponent.set_source: source must be an instance of FuelComponent");
        }

        # If this function is not overridden, then the FuelComponent is
        # an end-point, thus it has no source or sink. The only reason to
        # implement set_source() is because another component might call
        # it in its connect() function.
    },

    connect: func (sink) {
        sink.set_source(me);
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        die("FuelComponent.prepare_subtract_fuel_flow is abstract");
    },

    prepare_add_fuel_flow: func (flow, dt) {
        die("FuelComponent.prepare_add_fuel_flow is abstract");
    },

    execute_fuel_flow: func {
        die("FuelComponent.execute_fuel_flow is abstract");
    },

    update_current_flow: func (dt) {
        me.set_param("current-flow-gal_us-ps", me.current_gal_us / dt);
        me.current_gal_us = 0.0;
    },

    _add_current_flow: func (flow) {
        me.current_gal_us = me.current_gal_us + flow;
    }

};

var TransferableFuelComponent = {

    # An abstract class for components that connect two other
    # components.

    new: func (name, max_flow) {
        # Create a new instance of a TransferableFuelComponent.
        #
        # max_flow: The maximum flow (gal/s) that can flow between the
        #           two components.

        if (max_flow <= 0) {
            die("TransferableFuelComponent.new: max_flow (" ~ max_flow ~ ") must be greater than zero");
        }

        var m = {
            parents: [TransferableFuelComponent, FuelComponent.new(name)],
            source:  nil,
            sink:    nil,
            source_subtracted: nil,
            sink_added:        nil,
            transferred_flow:  0.0
        };

        m.node.setValues({
            "max-flow":              max_flow,
            "requested-flow-factor": 0.0,
            "actual-flow-factor":    0.0
        });

        return m;
    },

    set_source: func (source) {
        if (!isa(source, FuelComponent)) {
            die("TransferableFuelComponent.set_source: source must be an instance of FuelComponent");
        }
        if (me.source != nil) {
            die("Illegal call to TransferableFuelComponent.set_source: already connected");
        }

        me.source = source;
    },

    _set_sink: func (sink) {
        if (!isa(sink, FuelComponent)) {
            die("TransferableFuelComponent.set_sink: sink must be an instance of FuelComponent");
        }
        if (me.sink != nil) {
            die("Illegal call to TransferableFuelComponent.set_sink: already connected");
        }

        me.sink   = sink;
    },

    connect: func (sink) {
        me._set_sink(sink);
        sink.set_source(me);
    },

    get_max_flow: func {
        # Return the maximum possible flow.
        #
        # The returned value is always greater than zero.

        return me.get_param("max-flow");
    },

    set_flow_factor: func (factor) {
        # Set the flow requested flow factor.
        #
        # The factor must be in the range 0 .. 1.

        assert(0.0 <= factor and factor <= 1.0);

        me.set_param("requested-flow-factor", factor);
    },

    get_flow_factor: func {
        # Return the actual flow factor.
        #
        # In order to get the actual flow, call get_current_flow(), which
        # multiplies the returned value by the maximum possible flow.

        var flow_factor = me.get_param("actual-flow-factor");

        assert(debug.isnan(flow_factor) != 1.0);
        return flow_factor;
    },

    get_current_flow: func (dt) {
        # Return the actual flow. The value depends on the maximum
        # possible flow and the actual flow factor.

        return me.get_flow_factor() * me.get_max_flow() * dt;
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        assert(me.source != nil);
        assert(debug.isnan(flow) != 1.0);

        me.source_subtracted = 1.0;
        me.transferred_flow = me.source.prepare_subtract_fuel_flow(min(me.get_current_flow(dt), flow), dt);

        assert(me.transferred_flow >= 0.0);
        return me.transferred_flow;
    },

    test_subtract_fuel_flow: func (flow, dt) {
        assert(me.source != nil);
        assert(debug.isnan(flow) != 1.0);

        return me.source.test_subtract_fuel_flow(min(me.get_current_flow(dt), flow), dt);
    },

    prepare_add_fuel_flow: func (flow, dt) {
        assert(me.sink != nil);
        assert(debug.isnan(flow) != 1.0);

        me.sink_added = 1.0;
        me.transferred_flow = me.sink.prepare_add_fuel_flow(min(me.get_current_flow(dt), flow), dt);

        assert(me.transferred_flow >= 0.0);
        return me.transferred_flow;
    },

    test_add_fuel_flow: func (flow, dt) {
        assert(me.sink != nil);
        assert(debug.isnan(flow) != 1.0);

        return me.sink.test_add_fuel_flow(min(me.get_current_flow(dt), flow), dt);
    },

    execute_fuel_flow: func {
        assert(me.source != nil);
        assert(me.sink   != nil);

        if (me.source_subtracted != nil) {
            me.source.execute_fuel_flow();
        }
        if (me.sink_added != nil) {
            me.sink.execute_fuel_flow();
        }

        me._add_current_flow(me.transferred_flow);

        me.source_subtracted = nil;
        me.sink_added        = nil;
    }

};

var ActiveFuelComponent = {

    new: func (name, max_flow) {
        var m = {
            parents: [ActiveFuelComponent, TransferableFuelComponent.new(name, max_flow)],
        };
        return m;
    },

    transfer_fuel: func (dt) {
        die("ActiveFuelComponent.transfer_fuel is abstract");
    }

};

var Tank = {

    # A container that contains fuel.

    new: func (name, index, typical_level=nil) {
        var tank_property = props.globals.getNode("/consumables/fuel/tank[" ~ index ~ "]");
        var max_capacity  = tank_property.getNode("capacity-gal_us").getValue();

        if (typical_level == nil) {
            typical_level = max_capacity;
        }

        if (typical_level > max_capacity) {
            die("Tank.new: typical_level (" ~ typical_level ~ ") must be less than or equal to maximum capacity of tank (" ~ max_capacity ~ ")");
        }

        # Deselect the tank so that it doesn't get refuelled during
        # aerial refuelling
        tank_property.getNode("selected").setBoolValue(0);

        var m = {
            parents:  [Tank, FuelComponent.new("tank-" ~ name)],
            property: tank_property,
            new_level_gal_us: nil,
            transferred_flow: 0.0
        };

        m.node.setValues({
            "max-capacity":  max_capacity,
            "typical-level": typical_level
        });

        return m;
    },

    get_max_capacity: func {
        return me.get_param("max-capacity");
    },

    get_typical_level: func {
        return me.get_param("typical-level");
    },

    get_current_level: func {
        # Restrict level-gal_us to be within 0 .. max-capacity
        return max(0, min(me.property.getNode("level-gal_us").getValue(), me.get_max_capacity()));
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        var removed_gal_us = min(me.get_current_level(), flow);
        assert(0.0 <= removed_gal_us and removed_gal_us <= flow);
        me.transferred_flow = -removed_gal_us;

        me.new_level_gal_us = me.get_current_level() - removed_gal_us;

        return removed_gal_us;
    },

    test_subtract_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        var removed_gal_us = min(me.get_current_level(), flow);
        assert(0.0 <= removed_gal_us and removed_gal_us <= flow);

        return removed_gal_us;
    },

    prepare_add_fuel_flow: func (flow, dt) {
        # Note: dt is not needed here
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0);

        var added_gal_us = min(me.get_max_capacity() - me.get_current_level(), flow);
        assert(0.0 <= added_gal_us and added_gal_us <= flow);
        me.transferred_flow = added_gal_us;

        me.new_level_gal_us = me.get_current_level() + added_gal_us;

        return added_gal_us;
    },

    test_add_fuel_flow: func (flow, dt) {
        # Note: dt is not needed here
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0);

        var added_gal_us = min(me.get_max_capacity() - me.get_current_level(), flow);
        assert(0.0 <= added_gal_us and added_gal_us <= flow);

        return added_gal_us;
    },

    execute_fuel_flow: func {
        assert(me.new_level_gal_us != nil);

        me.property.getNode("level-gal_us").setValue(me.new_level_gal_us);
        me.new_level_gal_us = nil;

        me._add_current_flow(me.transferred_flow);

        assert(me.new_level_gal_us == nil);
    }

};

var LeakableTank = {

    # A tank that can leak under certain conditions. For example, during
    # takeoff of a SR-71 when the temperature of its fuselage is low, or
    # when the tank has been hit by bullets.

    new: func (name, index, typical_level, max_leak_flow, consumer) {
        if (!isa(consumer, AbstractConsumer)) {
            die("LeakableTank.new: consumer must be an instance of AbstractConsumer");
        }

        if (max_leak_flow <= 0) {
            die("LeakableTank.new: max_leak_flow (" ~ max_leak_flow ~ ") must be greater than zero");
        }

        var m = {
            parents:  [LeakableTank, Tank.new("leakable-" ~ name, index, typical_level)],
            consumer: consumer
        };

        m.node.setValues({
            "max-leak-flow": max_leak_flow,
            "leaking":       0.0
        });

        return m;
    }

    # TODO Implement sending some of the fuel to consumer instead of the sink

};

var ServiceableFuelComponentMixin = {

    # A mixin which, if inherited, makes the component serviceable.

    new: func {
        var m = {
            parents: [ServiceableFuelComponentMixin]
        };
        return m;
    },

    _new_serviceable: func {
        if (!isa(me, TransferableFuelComponent)) {
            die("ServiceableFuelComponentMixin._new_serviceable: component must be an instance of TransferableFuelComponent");
        }

        me.serviceable = me.node.initNode("serviceable", 0, "BOOL");
        me.selected = me.node.initNode("selected", 1, "BOOL");

        var enable_flow_factor = func {
            me.set_flow_factor(me.serviceable.getBoolValue() and me.selected.getBoolValue());
        };

        setlistener(me.serviceable.getPath(), func (node) enable_flow_factor(), 1, 0);
        setlistener(me.selected.getPath(), func (node) enable_flow_factor(), 1, 0);
    },

    enable: func {
        if (!me.is_enabled() and show_debug.getBoolValue()) {
            debug.dump(sprintf("Enabling component %s", me.get_name()));
        }
        me.serviceable.setBoolValue(1);
    },

    disable: func {
        if (me.is_enabled() and show_debug.getBoolValue()) {
            debug.dump(sprintf("Disabling component %s", me.get_name()));
        }
        me.serviceable.setBoolValue(0);
    },

    is_enabled: func {
        return me.serviceable.getBoolValue();
    }

};

var Valve = {

    # A component to provide or cut off the fuel flow. Only needs
    # electrical power when opening or closing.
    #
    # Call connect() to insert the valve between two components.

    new: func (name, max_flow) {
        var m = {
            parents: [Valve, ServiceableFuelComponentMixin.new(), TransferableFuelComponent.new("valve-" ~ name, max_flow)]
        };
        m._new_serviceable();
        return m;
    },

    is_open: func {
        return me.get_flow_factor() > 0.0;
    },

    get_open_position: func {
        return me.get_flow_factor();
    }

    # TODO Use the electrical bus to control me.set_flow_factor() when changing the factor

};

var Tube = {

    # A tube that can be used to transport fuel from a producer or tank
    # to a consumer or another tank. A tube can be used to restrict the
    # flow between two other components. For example, to simulate frozen
    # fuel.
    #
    # Call connect() to insert the tube between two components.

    new: func (name, max_flow) {
        var m = {
            parents: [Tube, TransferableFuelComponent.new("tube-" ~ name, max_flow)]
        };
        call(TransferableFuelComponent.set_flow_factor, [1.0], m);
        return m;
    }

};

var Manifold = {

    # A manifold distributes fuel from a source to all the sinks or from
    # a sink to all the sources using the maximum flow of the receiving
    # components for the ratio.

    new: func (name) {
        var m = {
            parents: [Manifold, FuelComponent.new("manifold-" ~ name)],
            sources:  std.Vector.new(),
            sinks:    std.Vector.new(),
            source_subtracted: nil,
            sink_added:        nil,
            total_flow_sources: 0.0,
            total_flow_sinks:   0.0,
            transferable_flow:  0.0,
            sources_flow: nil,
            sinks_flow:   nil
        };
        return m;
    },

    set_source: func (source) {
        if (!isa(source, TransferableFuelComponent)) {
            die("Manifold.set_source: source must be an instance of TransferableFuelComponent");
        }

        if (me.sources.contains(source.get_name())) {
            die("Illegal call to Manifold.set_source: already connected");
        }

        me.sources.append(source);
    },

    _set_sink: func (sink) {
        if (!isa(sink, TransferableFuelComponent)) {
            die("Manifold._set_sink: sink must be an instance of TransferableFuelComponent");
        }

        if (me.sinks.contains(sink.get_name())) {
            die("Illegal call to Manifold._set_sink: already connected");
        }

        me.sinks.append(sink);
    },

    connect: func (sink) {
        me._set_sink(sink);
        sink.set_source(me);
    },

    prepare_distribution: func (dt) {
        # Compute total flow over all the sources
        me.total_flow_sources = 0.0;
        me.sources_flow = std.Vector.new();
        foreach (var source; me.sources.vector) {
            var source_flow = source.test_subtract_fuel_flow(source.get_current_flow(dt), dt);
            me.total_flow_sources += source_flow;
            me.sources_flow.append([me.sources.index(source), source_flow]);
        }

        # Compute total flow over all the sinks
        me.total_flow_sinks = 0.0;
        me.sinks_flow = std.Vector.new();
        foreach (var sink; me.sinks.vector) {
            var sink_flow = sink.test_add_fuel_flow(sink.get_current_flow(dt), dt);
            me.total_flow_sinks += sink_flow;
            me.sinks_flow.append([me.sinks.index(sink), sink_flow]);
        }

        assert(me.total_flow_sources >= 0.0);
        assert(me.total_flow_sinks   >= 0.0);

        me.transferable_flow = min(me.total_flow_sources, me.total_flow_sinks);
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        assert(me.sources.size() > 0);
        assert(debug.isnan(flow) != 1.0);

        if (me.transferable_flow == 0.0) {
            return 0.0;
        }

        me.source_subtracted = 1.0;

        flow = flow / me.total_flow_sinks * me.transferable_flow;

        var usable_flow = 0.0;
        foreach (var tuple; me.sources_flow.vector) {
            var source_flow = tuple[1] / me.total_flow_sources * flow;
            usable_flow += me.sources.vector[tuple[0]].prepare_subtract_fuel_flow(source_flow, dt);
        }

        assert(usable_flow >= 0.0);
        return usable_flow;
    },

    prepare_add_fuel_flow: func (flow, dt) {
        assert(me.sinks.size() > 0);
        assert(debug.isnan(flow) != 1.0);

        if (me.transferable_flow == 0.0) {
            return 0.0;
        }

        me.sink_added = 1.0;

        flow = flow / me.total_flow_sources * me.transferable_flow;

        var usable_flow = 0.0;
        foreach (var tuple; me.sinks_flow.vector) {
            var sink_flow = tuple[1] / me.total_flow_sinks * flow;
            usable_flow += me.sinks.vector[tuple[0]].prepare_add_fuel_flow(sink_flow, dt);
        }

        assert(usable_flow >= 0.0);
        return usable_flow;
    },

    execute_fuel_flow: func {
        assert(me.sources.size() > 0);
        assert(me.sinks.size() > 0);

        if (me.source_subtracted != nil) {
            foreach (var source; me.sources.vector) {
                source.execute_fuel_flow();
            }
        }
        if (me.sink_added != nil) {
            foreach (var sink; me.sinks.vector) {
                sink.execute_fuel_flow();
            }
        }

        me._add_current_flow(me.transferable_flow);

        me.source_subtracted = nil;
        me.sink_added        = nil;
    }

};

var AbstractPump = {

    new: func (name, max_flow) {
        var m = {
            parents: [AbstractPump, ActiveFuelComponent.new("pump-" ~ name, max_flow)]
        };
        return m;
    },

    transfer_fuel: func (dt) {
        assert(me.source != nil);
        assert(me.sink   != nil);

        var current_flow = me.get_current_flow(dt);

        if (current_flow > 0.0) {
            var available_flow = me.source.prepare_subtract_fuel_flow(current_flow, dt);

            # Try to add the available flow to the receiving component
            var actual_flow = me.sink.prepare_add_fuel_flow(available_flow, dt);

            # The receiving component might have less volume available than
            # the sending component, so update the actual available flow.
            var flow = me.source.prepare_subtract_fuel_flow(actual_flow, dt);

            assert(abs(flow - actual_flow) <= 0.0000001);
            if (flow > 0.0 and show_debug.getBoolValue()) {
                debug.dump(sprintf("%s transferred %.4f out of %.4f", me.get_name(), flow, available_flow));
            }

            # Now actually transfer the fuel
            me.source.execute_fuel_flow();
            me.sink.execute_fuel_flow();

            me._add_current_flow(flow);
        }
    }

};

var BoostPump = {

    # A pump which will maximize the flow if the electrical bus provides
    # sufficient power.
    #
    # Call connect() to insert the boost pump between two components.

    new: func (name, max_flow) {
        var m = {
            parents: [BoostPump, ServiceableFuelComponentMixin.new(), AbstractPump.new("boost-" ~ name, max_flow)]
        };
        m._new_serviceable();
        return m;
    },

    is_active: func {
        return me.get_flow_factor() > 0.0;
    }

    # TODO Use the electrical bus to control me.set_flow_factor()

};

var AutoPump = {

    # A pump which will always maximize the flow. You need to attach an
    # AutoPump to an EngineConsumer to make it demand fuel, since an
    # EngineConsumer is by itself passive.
    #
    # Call connect() to insert the auto pump between two components.

    new: func (name, max_flow) {
        var m = {
            parents: [AutoPump, AbstractPump.new("auto-" ~ name, max_flow)]
        };
        call(TransferableFuelComponent.set_flow_factor, [1.0], m);
        return m;
    }

};

var GravityPump = {

    # A pump which will try to maximize the flow depending on the g load factor.
    #
    # Call connect() to insert the gravity pump between two components.

    new: func (name, max_flow) {
        var m = {
            parents: [GravityPump, AbstractPump.new("gravity-" ~ name, max_flow)]
        };
        return m;
    }

    # TODO Use g load factor to control me.set_flow_factor()

};

var AbstractConsumer = {

    new: func (name) {
        var m = {
            parents: [AbstractConsumer, FuelComponent.new("consumer-" ~ name)]
        };
        return m;
    },

    test_subtract_fuel_flow: func (flow, dt) {
        die("Illegal call to AbstractConsumer.test_subtract_fuel_flow: consumer cannot provide fuel");
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        die("Illegal call to AbstractConsumer.prepare_subtract_fuel_flow: consumer cannot provide fuel");
    },

    execute_fuel_flow: func {
        if (me.consumed_gal_us != nil) {
            me._add_current_flow(me.consumed_gal_us);
        }
        me.consumed_gal_us = nil;
    }

};

var EngineConsumer = {

    # A consumer that consumes fuel based on a certain demand.
    #
    # Since an EngineConsumer is a passive component, you need to attach
    # a pump to it in order to make it demand fuel. It is recommended to
    # attach an AutoPump which will always feed fuel to the engines.
    #
    # Make sure to give the AutoPump a max_flow >= max{engine(flow)} so
    # that it does not unncessarily restrict the flow and that all logic
    # that determines how much fuel is demanded is located only within
    # the engine() function.

    new: func (name, engine) {
        # Create a new instance of EngineConsumer.
        #
        # engine: A function f(flow) that is given a certain amount of
        #         flow (gal/s) to be used to let the engine provide the
        #         desired thrust. It must return a value that represents
        #         the used flow and must be within 0 .. flow. If the engines
        #         need a higher flow to provide the desired thrust, then the
        #         engines have no choice but to provide less thrust than desired.

        if (typeof(engine) != "func") {
            die("EngineConsumer.new: engine must be a function");
        }

        var m = {
            parents: [EngineConsumer, AbstractConsumer.new("engine-" ~ name)],
            engine:  engine,
            consumed_gal_us: nil
        };
        return m;
    },

    test_add_fuel_flow: func (flow, dt) {
        # Note: dt is not needed here
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        var consumed_gal_us = me.engine(flow, dt);

        assert(0.0 <= consumed_gal_us and consumed_gal_us <= flow);
        return consumed_gal_us;
    },

    prepare_add_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        me.consumed_gal_us = me.engine(flow, dt);

        assert(0.0 <= me.consumed_gal_us and me.consumed_gal_us <= flow);
        return me.consumed_gal_us;
    }

};

var JettisonConsumer = {

    # A consumer that will always consume any fuel it is given.

    new: func (name) {
        var m = {
            parents: [JettisonConsumer, AbstractConsumer.new("jettison-" ~ name)],
            consumed_gal_us: nil
        };
        return m;
    },

    test_add_fuel_flow: func (flow, dt) {
        # Note: dt is not needed here
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        return flow;
    },

    prepare_add_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        me.consumed_gal_us = flow;

        return me.consumed_gal_us;
    }

};

var AbstractProducer = {

    new: func (name) {
        var m = {
            parents: [AbstractProducer, FuelComponent.new("producer-" ~ name)]
        };
        return m;
    },

    test_add_fuel_flow: func (flow, dt) {
        die("Illegal call to AbstractProducer.test_add_fuel_flow: provider cannot consume fuel");
    },

    prepare_add_fuel_flow: func (flow, dt) {
        die("Illegal call to AbstractProducer.prepare_add_fuel_flow: provider cannot consume fuel");
    },

    execute_fuel_flow: func {
        # No operation
    }

};

var AirRefuelProducer = {

    # A producer that produces fuel based on the flow rate provided by
    # a tanker.
    #
    # Since an AirRefuelProducer is a passive component, you need to attach
    # it to a pump in order to make it produce fuel.

    new: func (name, probe) {
        # Create a new instance of AirRefuelProducer.
        #
        # probe: A function f() that returns the receivable flow (gal/s)
        #        that can be pumped into the system. It must return a value
        #        that is greater than or equal to 0.

        if (typeof(probe) != "func") {
            die("AirRefuelProducer.new: probe must be a function");
        }

        var m = {
            parents: [AirRefuelProducer, AbstractProducer.new("air-refuel-" ~ name)],
            probe:   probe,
            provided_gal_us: nil
        };
        m.refuel_contact = props.globals.initNode("/systems/refuel/contact", 0, "BOOL");
        m.ai_models = props.globals.getNode("/ai/models", 1);

        return m;
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        # This component is going to be a source for another component,
        # which means this function will get called twice
        if (me.provided_gal_us == nil) {
            me.provided_gal_us = me._get_receivable_fuel_flow(dt);
        }
        me.provided_gal_us = min(me.provided_gal_us, flow);

        assert(0.0 <= me.provided_gal_us and me.provided_gal_us <= flow);
        return me.provided_gal_us;
    },

    execute_fuel_flow: func {
        if (me.provided_gal_us != nil) {
            me._add_current_flow(me.provided_gal_us);
            if (me.provided_gal_us > 0.0 and show_debug.getBoolValue()) {
                debug.dump("Receiving " ~ me.provided_gal_us ~ " gal of fuel from tanker");
            }
        }
        me.provided_gal_us = nil;
    },

    _get_receivable_fuel_flow: func (dt) {
        if (!getprop("/sim/ai/enabled")) {
            return 0.0;
        }

        var tanker = nil;
        var type = getprop("/systems/refuel/type");

        # Check for contact with tanker aircraft
        var ac = me.ai_models.getChildren("tanker");
        var mp = me.ai_models.getChildren("multiplayer");

        # Collect a list of tankers that we are in contact with
        foreach (var a; ac ~ mp) {
            if (!a.getNode("valid", 1).getValue()
             or !a.getNode("tanker", 1).getValue()
             or !a.getNode("refuel/contact", 1).getValue()) {
                continue;
            }

            foreach (var refuel_type; a.getNode("refuel", 1).getChildren("type")) {
                if (type == refuel_type.getValue()) {
                    # TODO Override if distance to drogue/boom is closer than the current tanker
                    tanker = a;
                    break;
                }
            }
        }

        var refueling = getprop("/systems/refuel/serviceable") and tanker != nil;

        if (getprop("/systems/refuel/report-contact")) {
            if (refueling and !me.refuel_contact.getValue()) {
                setprop("/sim/messages/copilot", "Engage");
            }
            if (!refueling and me.refuel_contact.getValue()) {
                setprop("/sim/messages/copilot", "Disengage");
            }
        }
        me.refuel_contact.setBoolValue(refueling);

        if (getprop("/sim/freeze/fuel") or !refueling) {
            return 0.0;
        }

        var flow = me.probe(tanker, dt);

        assert(flow >= 0.0);
        return flow;
    }

};

var GroundRefuelProducer = {

    # A producer that produces fuel based on the flow rate provided by
    # a fuel truck.
    #
    # Since an GroundRefuelProducer is a passive component, you need to attach
    # it to a pump in order to make it produce fuel.

    new: func (name, contact_point) {
        # Create a new instance of GroundRefuelProducer.
        #
        # contact_point: A function f() that returns the receivable flow (gal/s)
        #                that can be pumped into the system. It must return
        #                a value that is greater than or equal to 0.

        if (typeof(contact_point) != "func") {
            die("GroundRefuelProducer.new: contact_point must be a function");
        }

        var m = {
            parents: [GroundRefuelProducer, AbstractProducer.new("ground-refuel-" ~ name)],
            contact_point:   contact_point,
            provided_gal_us: nil
        };
        m.fuel_truck = props.globals.initNode("/systems/refuel-ground");

        m.refuel_contact   = m.fuel_truck.initNode("refuel", 0, "BOOL");
        m.level_gal_us     = m.fuel_truck.initNode("level-gal_us", 0.0, "DOUBLE");
        m.transfer_lbs_min = m.fuel_truck.initNode("max-fuel-transfer-lbs-min", 6000, "INT");

        m.x_m = m.fuel_truck.initNode("x-m", 0.0, "DOUBLE");
        m.y_m = m.fuel_truck.initNode("y-m", 0.0, "DOUBLE");

        return m;
    },

    prepare_subtract_fuel_flow: func (flow, dt) {
        assert(debug.isnan(flow) != 1.0);
        assert(flow >= 0.0);

        # This component is going to be a source for another component,
        # which means this function will get called twice
        if (me.provided_gal_us == nil) {
            me.provided_gal_us = me._get_receivable_fuel_flow(dt);
        }
        me.provided_gal_us = min(me.provided_gal_us, flow);

        assert(0.0 <= me.provided_gal_us and me.provided_gal_us <= flow);
        return me.provided_gal_us;
    },

    execute_fuel_flow: func {
        if (me.provided_gal_us != nil) {
            me._add_current_flow(me.provided_gal_us);
            if (me.provided_gal_us > 0.0 and show_debug.getBoolValue()) {
                debug.dump("Receiving " ~ me.provided_gal_us ~ " gal of fuel from fuel truck");
            }

            var truck_total_gal_us = me.level_gal_us.getValue();
            me.level_gal_us.setValue(truck_total_gal_us - me.provided_gal_us);
        }
        me.provided_gal_us = nil;
    },

    _get_receivable_fuel_flow: func (dt) {
        if (!me.refuel_contact.getBoolValue()) {
            return 0.0;
        }

        var flow = me.contact_point(me.fuel_truck, dt);

        assert(flow >= 0.0);
        return flow;
    }

};

var connect = func (components) {
    var current = nil;

    foreach (var component; components) {
        if (current != nil) {
            current.connect(component);
        }
        current = component;
    }
};

var make_tank_levels_persistent = func {
    # Make tank levels persistent across sessions
    foreach (var tank; props.globals.getNode("/consumables/fuel").getChildren("tank")) {
        aircraft.data.add(tank.getNode("level-gal_us").getPath());
    }
    aircraft.data.load();
};

var Network = {

    new: func {
        var m = {
            parents:    [Network],
            components: std.Vector.new(),
            manifolds:  std.Vector.new(),
            pumps:      std.Vector.new(),
        };
        return m;
    },

    add: func (component) {
        me.components.append(component);
        if (show_debug.getBoolValue()) {
            debug.dump(sprintf("Added component %s", component.get_name()));
        }

        # Add if pump
        if (isa(component, AbstractPump)) {
            me.pumps.append(component);
        }

        # Add if manifold
        if (isa(component, Manifold)) {
            me.manifolds.append(component);
        }
    },

    update: func (dt) {
        # Prepare fair distribution by manifolds
        foreach (var manifold; me.manifolds.vector) {
            manifold.prepare_distribution(dt);
        }

        # Let pumps transfer fuel
        foreach (var pump; me.pumps.vector) {
            pump.transfer_fuel(dt);
        }

        # Update current flow gal/s counters of components
        foreach (var component; me.components.vector) {
            component.update_current_flow(dt);
        }
    }

};

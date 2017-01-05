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

globals.io.import = func (file, module) {
    file = string.normpath(file);

    var local_file = globals.io.dirname(caller()[2]) ~ file;
    var path = (globals.io.stat(local_file) != nil)? local_file : resolvepath(file);

    if (path == "") {
        canvas.MessageBox.critical(
            "Module not found",
            sprintf("Could not import module '%s' from ExpansionPack.", module)
        );
        die("File not found: ", file);
    };

    globals.io.load_nasal(path, module);
};

var with = func (modules...) {
    foreach (module; modules) {
        if (!string.match(module, "*[a-z]")) {
            die(sprintf("Error: invalid module name: '%s'", module));
        }

        io.import("Aircraft/ExpansionPack/Nasal/" ~ module ~ ".nas", module);
    }
};

var check_version = func (module, major, minor) {
    if (!contains(globals, module) or typeof(globals[module]) != "hash") {
        die("check_version(): module not imported");
    }

    var version_major = globals[module].version.major;
    var version_minor = globals[module].version.minor;

    var version_ok = (version_major == major and version_minor >= minor);

    if (!version_ok) {
        var format  = "Module '%s' requires version %d.%d, but ExpansionPack provides version %d.%d";
        var message = sprintf(format, module, major, minor, version_major, version_minor);

        with("logger");
        logger.error(message);

        canvas.MessageBox.critical(
            "Incompatible module version",
            message ~ "."
        );

        # Continuing with an old and incompatible version of the module is
        # stupid and may cause strange bugs.
        die(message);
    }
};

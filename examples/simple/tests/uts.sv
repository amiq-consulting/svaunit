/******************************************************************************
 * (C) Copyright 2015 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME:        uts.sv
 * PROJECT:     svaunit
 * Description: SVAUnit test suite
 *******************************************************************************/

`ifndef __UTS_SV
//protection against multiple includes
`define __UTS_SV

// Unit test suite for a simple example
class uts extends svaunit_test_suite;
    `uvm_component_utils(uts)

    // Define unit tests used to verify AN_SVA
    ut1 unit_test1;
    ut2#(10) unit_test2;

    /* Constructor for uts
     * @param name   : instance name for uts object
     * @param parent : hierarchical parent for uts
     */
    function new(string name = "uts", uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        // Create and instantiate unit tests
        unit_test1 = ut1::type_id::create("unit_test1", this);
        unit_test2 = ut2#(10)::type_id::create("unit_test2", this);

        // Register unit tests to test suite
        add_test(unit_test1);
        add_test(unit_test2);
    endfunction
endclass

`endif

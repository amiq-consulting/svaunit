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
 * NAME:        apb_ts.sv
 * PROJECT:     svaunit
 * Description: Test runner class for APB SVAs
 *******************************************************************************/

`ifndef __APB_TS_SV
//protection against multiple includes
`define __APB_TS_SV

// Test runner class for APB SVAs
class apb_ts extends svaunit_test_suite;
    `uvm_component_utils(apb_ts)

    // Test suite for after reset unit tests
    after_reset_ts after_reset_suite;

    // Test suite for x/z unit tests
    x_z_ts x_z_suite;

    // Test suite for protocol unit tests
    protocol_ts protocol_suite;

    /* Constructor for apb_ts
     * @param name   : instance name for apb_ts object
     * @param parent : hierarchical parent for apb_ts
     */
    function new(input string name = "apb_ts", input uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Create and instantiate after_reset test suite
        after_reset_suite = after_reset_ts::type_id::create("after_reset_suite", this);

        // Create and instantiate x_z test suite
        x_z_suite = x_z_ts::type_id::create("x_z_suite", this);

        // Create and instantiate protocol test suite
        protocol_suite = protocol_ts::type_id::create("protocol_suite", this);

        // Register unit tests to test suite
        add_test(after_reset_suite);
        add_test(x_z_suite);
        add_test(protocol_suite);
    endfunction
endclass

`endif

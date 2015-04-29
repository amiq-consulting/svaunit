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
 * NAME:        after_reset_ts.sv
 * PROJECT:     svaunit
 * Description: Unit test suite for those tests which verify after reset SVA
 *******************************************************************************/

`ifndef __AFTER_RESET_TS_SV
//protection against multiple includes
`define __AFTER_RESET_TS_SV

// Unit test suite for those tests which verify after reset SVA
class after_reset_ts extends svaunit_test_suite;
    `uvm_component_utils(after_reset_ts)

    // Define unit test for checking enable after reset
    after_reset_enable_ut#(10, 10) enable_after_reset_test;

        // Define unit test for checking enable after reset
    after_reset_enable_ut#(10) enable_after_reset_test12;

    // Define unit test for checking slverr after reset
    after_reset_slverr_ut#(10) slverr_after_reset_test;

    // Define unit test for checking sel after reset
    after_reset_sel_ut#(10) sel_after_reset_test;

    x_z_ts x_z_test_suite;

    /* Constructor for after_reset_ts
     * @param name   : instance name for after_reset_ts object
     * @param parent : hierarchical parent for after_reset_ts
     */
    function new(input string name = "after_reset_ts", input uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Create and instantiate unit test for checking enable after reset
        enable_after_reset_test = after_reset_enable_ut#(10, 10)::type_id::create("enable_after_reset_test", this);

        // Create and instantiate unit test for checking enable after reset
        enable_after_reset_test12 = after_reset_enable_ut#(10)::type_id::create("enable_after_reset_test12", this);

        // Create and instantiate unit test for checking slverr after reset
        slverr_after_reset_test = after_reset_slverr_ut#(10)::type_id::create("slverr_after_reset_test", this);

        // Create and instantiate unit test for checking sel after reset
        sel_after_reset_test = after_reset_sel_ut#(10)::type_id::create("sel_after_reset_test", this);

        x_z_test_suite = x_z_ts::type_id::create("ax_z_ts", this);

        // Register unit tests to test suite
        add_test(enable_after_reset_test);
        add_test(enable_after_reset_test12);
        add_test(slverr_after_reset_test);
        add_test(sel_after_reset_test);
        add_test(sel_after_reset_test);
        add_test(x_z_test_suite);
    endfunction
endclass

`endif

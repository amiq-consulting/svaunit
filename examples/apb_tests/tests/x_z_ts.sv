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
 * NAME:        x_z_ts.sv
 * PROJECT:     svaunit
 * Description: Unit test suite for those tests which verify X/Z SVA
 *******************************************************************************/

`ifndef __X_Z_TS_SV
//protection against multiple includes
`define __X_Z_TS_SV

// Unit test suite for those tests which verify after reset SVA
class x_z_ts extends svaunit_test_suite;
    `uvm_component_utils(x_z_ts)

    // Define unit test used to verify addr illegal value
    x_z_addr_ut#(10) addr_x_z_test;

    // Define unit test used to verify enable illegal value
    x_z_enable_ut#(10) enable_x_z_test;

    // Define unit test used to verify prot illegal value
    x_z_prot_ut#(10) prot_x_z_test;

    // Define unit test used to verify ready illegal value
    x_z_ready_ut#(10) ready_x_z_test;

    // Define unit test used to verify sel illegal value
    x_z_sel_ut#(10) sel_x_z_test;

    // Define unit test used to verify slverr illegal value
    x_z_slverr_ut#(10) slverr_x_z_test;

    // Define unit test used to verify strb illegal value
    x_z_strb_ut#(10) strb_x_z_test;

    // Define unit test used to verify write illegal value
    x_z_write_ut#(10) write_x_z_test;

    /* Constructor for x_z_ts
     * @param name   : instance name for x_z_ts object
     * @param parent : hierarchical parent for x_z_ts
     */
    function new(input string name = "x_z_ts", input uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Create and instantiate unit test used to verify addr illegal value
        addr_x_z_test = x_z_addr_ut#(10)::type_id::create("addr_x_z_test", this);

        // Create and instantiate unit test used to verify enable illegal value
        enable_x_z_test = x_z_enable_ut#(10)::type_id::create("enable_x_z_test", this);

        // Create and instantiate unit test used to verify prot illegal value
        prot_x_z_test = x_z_prot_ut#(10)::type_id::create("prot_x_z_test", this);

        // Create and instantiate unit test used to verify ready illegal value
        ready_x_z_test = x_z_ready_ut#(10)::type_id::create("ready_x_z_test", this);

        // Create and instantiate unit test used to verify sel illegal value
        sel_x_z_test = x_z_sel_ut#(10)::type_id::create("sel_x_z_test", this);

        // Create and instantiate unit test used to verify slverr illegal value
        slverr_x_z_test = x_z_slverr_ut#(10)::type_id::create("slverr_x_z_test", this);

        // Create and instantiate unit test used to verify strb illegal value
        strb_x_z_test = x_z_strb_ut#(10)::type_id::create("strb_x_z_test", this);

        // Create and instantiate unit test used to verify write illegal value
        write_x_z_test = x_z_write_ut#(10)::type_id::create("write_x_z_test", this);

        // Register unit tests to test suite
        add_test(addr_x_z_test);
        add_test(enable_x_z_test);
        add_test(prot_x_z_test);
        add_test(ready_x_z_test);
        add_test(sel_x_z_test);
        add_test(slverr_x_z_test);
        add_test(strb_x_z_test);
        add_test(write_x_z_test);
    endfunction
endclass

`endif

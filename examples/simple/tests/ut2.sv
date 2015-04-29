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
 * NAME:        ut2.sv
 * PROJECT:     svaunit
 * Description: Unit test with a parameter used to verify AN_SVA
 *******************************************************************************/

`ifndef __UT2_SV
//protection against multiple includes
`define __UT2_SV

// Unit test used to verify the AN_SVA - example with a parameter
class ut2#(int unsigned A_PARAM = 10) extends svaunit_test;
    `uvm_component_param_utils(ut2#(A_PARAM))
    `SVAUNIT_TEST_WITH_PARAM_UTILS

    // Reference to virtual interface containing the SVA
    virtual an_interface vif;

    /* Constructor for ut2
     * @param name   : instance name for ut2 object
     * @param parent : hierarchical parent for ut2
     */
    function new(string name = "ut2", uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Get the reference to an_interface from UVM config db
       if (!uvm_config_db#(virtual an_interface)::get(uvm_root::get(), "*", "VIF", vif)) begin
            `uvm_fatal("SVAUNIT_NO_VIF_ERR", $sformatf("SVA interface for %s unit test is not set!", get_test_name()));
        end
    endfunction

    // Initialize signals
    task pre_test();
        vif.enable =  1'b0;
        vif.ready  =  1'b0;
        vif.sel    =  1'b0;
        vif.slverr =  1'b0;
    endtask

     // Create scenarios for AN_SVA
    task test();
        `uvm_info(get_test_name(), "START RUN PHASE", UVM_LOW)

        disable_all_assertions();
        enable_assertion("AN_SVA");

        repeat(2) @(posedge vif.clk);
        repeat(2) begin
            @(posedge vif.clk);
            fail_if_sva_not_succeeded("AN_SVA", "The assertion should have succeeded");
        end
        @(posedge vif.clk);

        // Enable error scenario
        vif.slverr = 1'b1;
        @(posedge vif.clk);

        repeat(2) begin
            @(posedge vif.clk);
            fail_if_sva_succeeded("AN_SVA", "The assertion should have failed");
        end

        vif.slverr = 1'b0;
        @(posedge  vif.clk);

        `uvm_info(get_test_name(), "END RUN PHASE", UVM_LOW)
    endtask
endclass

`endif

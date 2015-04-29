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
 * NAME:        protocol_ut14.sv
 * PROJECT:     svaunit
 * Description: Unit test used to verify the AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR
 *******************************************************************************/

`ifndef __PROTOCOL_UT14_SV
//protection against multiple includes
`define __PROTOCOL_UT14_SV

// Unit test used to verify the AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR SVA
class protocol_ut14 extends svaunit_test;
    `uvm_component_utils(protocol_ut14)

    // Reference to virtual interface containing the SVAs
    virtual amiq_apb_if#(.ready_low_max_time(10)) apb_vif;

    /* Constructor for protocol_ut14
     * @param name   : instance name for protocol_ut14 object
     * @param parent : hierarchical parent for protocol_ut14
     */
    function new(string name = "protocol_ut14", uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Get the APB interface from UVM config db
        if (!uvm_config_db#(virtual amiq_apb_if#(.ready_low_max_time(10)))::get(uvm_root::get(), "*", "apb_vif10", apb_vif)) begin
            `uvm_fatal("APB_SVAUNIT_NO_VIF_ERR", $sformatf("SVA interface with parameter : %0d for %s unit test is not set!", 10, get_name()));
        end
    endfunction

    // Initialize signals
    task pre_test();
        apb_vif.reset_n = 0;
        apb_vif.en_x_z_checks    = 0;
        apb_vif.en_rst_checks    = 0;
        apb_vif.has_error_signal = 1;
        apb_vif.addr   = 32'b0;
        apb_vif.enable =  1'b0;
        apb_vif.prot   =  3'b0;
        apb_vif.ready  =  1'b0;
        apb_vif.sel    =  1'b0;
        apb_vif.slverr =  1'b0;
        apb_vif.strb   =  4'b0;
        apb_vif.write  =  1'b0;
    endtask

    // Create scenarios for AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR
    task test();
        `uvm_info(get_test_name(), "START RUN PHASE", UVM_LOW)
        disable_all_assertions();
        enable_assertion("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR");

        @(posedge apb_vif.clk);
        apb_vif.reset_n = 1;
        @(posedge apb_vif.clk);
        apb_vif.sel    =  1'b0;
        fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");
        @(posedge apb_vif.clk);
        apb_vif.sel    =  1;
        fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");

        for(int position = 0; position < 16; position = position + 1) begin
            @(posedge apb_vif.clk);
            apb_vif.sel <= apb_vif.sel << 1;
            fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");
        end

        @(posedge apb_vif.clk);
        apb_vif.sel    =  1;
        fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");
        apb_vif.sel <= 3;
        @(posedge apb_vif.clk);

        for(int position = 0; position < 16; position = position + 1) begin
            @(posedge apb_vif.clk);
            apb_vif.sel <= apb_vif.sel << 1;
            fail_if_sva_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");
        end

        apb_vif.sel    =  1;
        @(posedge apb_vif.clk);
        fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR", "AMIQ_APB_ILLEGAL_SEL_LEGAL_VALUES_ERR should have succeeded");

        `uvm_info(get_test_name(), "END RUN PHASE", UVM_LOW)
    endtask
endclass

`endif

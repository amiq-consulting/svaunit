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
 * NAME:        amiq_svaunit_ex_apb_test_x_z_prot.sv
 * PROJECT:     svaunit
 * Description: Unit test used to verify the AMIQ_APB_ILLEGAL_PROT_VALUE_ERR SVA
 *******************************************************************************/

`ifndef AMIQ_SVAUNIT_EX_APB_TEST_X_Z_PROT_SV
`define AMIQ_SVAUNIT_EX_APB_TEST_X_Z_PROT_SV

// Unit test used to verify the AMIQ_APB_ILLEGAL_PROT_VALUE_ERR SVA
class amiq_svaunit_ex_apb_test_x_z_prot#(int unsigned MAXIM_LOW_TIME = 10) extends svaunit_test;
   `uvm_component_param_utils(amiq_svaunit_ex_apb_test_x_z_prot#(MAXIM_LOW_TIME))

   `SVAUNIT_TEST_WITH_PARAM_UTILS

   // Reference to virtual interface containing the SVAs
   local virtual amiq_apb_if#(.ready_low_max_time(MAXIM_LOW_TIME)) apb_vif;

   /* Constructor for amiq_svaunit_ex_apb_test_x_z_prot
    * @param name   : instance name for amiq_svaunit_ex_apb_test_x_z_prot object
    * @param parent : hierarchical parent for amiq_svaunit_ex_apb_test_x_z_prot
    */
   function new(string name = "amiq_svaunit_ex_apb_test_x_z_prot", uvm_component parent);
      super.new(name, parent);
   endfunction

   /* Build phase method used to instantiate components
    * @param phase : the phase scheduled for build_phase method
    */
   virtual function void build_phase(input uvm_phase phase);
      super.build_phase(phase);

      // Get the APB interface from UVM config db
      if (!uvm_config_db#(virtual amiq_apb_if#(.ready_low_max_time(MAXIM_LOW_TIME)))::get(uvm_root::get(), "*",
               $sformatf("apb_vif%0d", MAXIM_LOW_TIME), apb_vif)) begin
         `uvm_fatal("APB_SVAUNIT_NO_VIF_ERR", $sformatf("SVA interface for %s unit test is not set!", get_name()))
      end
   endfunction

   // Create scenarios for AMIQ_APB_ILLEGAL_PROT_VALUE_ERR
   virtual task test();
      `uvm_info(get_test_name(), "START RUN PHASE", UVM_LOW)

      // Initialize signals
      apb_vif.reset_n <= 0;
      apb_vif.en_protocol_checks <= 0;
      apb_vif.en_rst_checks      <= 0;
      apb_vif.has_error_signal   <= 0;
      apb_vif.addr   <= 32'b0;
      apb_vif.enable <=  1'b0;
      apb_vif.prot   <=  3'b0;
      apb_vif.ready  <=  1'b0;
      apb_vif.sel    <=  1'b0;
      apb_vif.slverr <=  1'b0;
      apb_vif.strb   <=  4'b0;
      apb_vif.write  <=  1'b0;

      vpiw.disable_all_assertions();
      vpiw.enable_assertion("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR");

      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);

      apb_vif.reset_n <= 1;
      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);

      @(posedge apb_vif.clk);
      apb_vif.prot   <= 3'bx;

      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);
      vpiw.fail_if_sva_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR", "The assertion should have failed");

      apb_vif.prot   <= 3'b0;

      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);
      vpiw.fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR", "The assertion should have succeeded");

      apb_vif.prot   <= 3'bz;

      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);
      vpiw.fail_if_sva_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR", "The assertion should have failed");

      apb_vif.prot   <= 3'b1;

      @(posedge apb_vif.clk);
      @(posedge apb_vif.clk);
      vpiw.fail_if_sva_not_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR", "The assertion should have succeeded");

      vpiw.fail_if(vpiw.get_nof_times_assertion_failed("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR") < 2, $sformatf(
            "FAILED: %0d, should >= 2", vpiw.get_nof_times_assertion_failed("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR")));
      vpiw.fail_if(vpiw.get_nof_times_assertion_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR") < 2, $sformatf(
            "SUCCEEDED: %0d, should >= 2", vpiw.get_nof_times_assertion_succeeded("AMIQ_APB_ILLEGAL_PROT_VALUE_ERR")));

      `uvm_info(get_test_name(), "END RUN PHASE", UVM_LOW)
   endtask
endclass

`endif

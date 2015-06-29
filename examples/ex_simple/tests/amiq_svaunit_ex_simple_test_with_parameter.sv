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
 * NAME:        amiq_svaunit_ex_simple_test_with_parameter.sv
 * PROJECT:     svaunit
 * Description: Unit test with a parameter used to verify AN_SVA
 *******************************************************************************/

`ifndef AMIQ_SVAUNIT_EX_SIMPLE_TEST_WITH_PARAMETER_SV
`define AMIQ_SVAUNIT_EX_SIMPLE_TEST_WITH_PARAMETER_SV

// Unit test used to verify the AN_SVA - example with a parameter
class amiq_svaunit_ex_simple_test_with_parameter#(int unsigned A_PARAM = 10) extends svaunit_test;
   `uvm_component_param_utils(amiq_svaunit_ex_simple_test_with_parameter#(A_PARAM))
   `SVAUNIT_TEST_WITH_PARAM_UTILS

   // Reference to virtual interface containing the SVA
   local virtual an_interface an_vif;

   /* Constructor for amiq_svaunit_ex_simple_test_with_parameter
    * @param name   : instance name for amiq_svaunit_ex_simple_test_with_parameter object
    * @param parent : hierarchical parent for amiq_svaunit_ex_simple_test_with_parameter
    */
   function new(string name = "amiq_svaunit_ex_simple_test_with_parameter", uvm_component parent);
      super.new(name, parent);
   endfunction

   /* Build phase method used to instantiate components
    * @param phase : the phase scheduled for build_phase method
    */
   virtual function void build_phase(input uvm_phase phase);
      super.build_phase(phase);

      // Get the reference to an_interface from UVM config db
      if (!uvm_config_db#(virtual an_interface)::get(uvm_root::get(), "*", "VIF", an_vif)) begin
         `uvm_fatal("SVAUNIT_NO_VIF_ERR", $sformatf("SVA interface for %s unit test is not set!", get_test_name()))
      end
   endfunction

   // Create scenarios for AN_SVA
   virtual task test();
      `uvm_info(get_test_name(), "START RUN PHASE", UVM_LOW)

      // Initialize signals
      an_vif.enable <=  1'b0;
      an_vif.ready  <=  1'b0;
      an_vif.sel    <=  1'b0;
      an_vif.slverr <=  1'b0;

      vpiw.disable_all_assertions();
      @(posedge an_vif.clk);
      vpiw.enable_assertion("AN_SVA");

      repeat(2) @(posedge an_vif.clk);
      repeat(2) begin
         @(posedge an_vif.clk);
         vpiw.fail_if_sva_not_succeeded("AN_SVA", "The assertion should have succeeded");
      end
      @(posedge an_vif.clk);

      // Enable error scenario
      an_vif.slverr <= 1'b1;
      @(posedge an_vif.clk);

      repeat(2) begin
         @(posedge an_vif.clk);
         vpiw.fail_if_sva_succeeded("top.an_if.AN_SVA", "The assertion should have failed");
      end

      an_vif.slverr <= 1'b0;
      @(posedge  an_vif.clk);

      `uvm_info(get_test_name(), "END RUN PHASE", UVM_LOW)
   endtask
endclass

`endif

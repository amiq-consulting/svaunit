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
 * NAME:        amiq_svaunit_ex_apb_test_protocol_test_suite.sv
 * PROJECT:     svaunit
 * Description: Unit test suite for those tests which verify protocol SVA
 *******************************************************************************/

`ifndef AMIQ_SVAUNIT_EX_APB_TEST_PROTOCOL_TEST_SUITE_SV
`define AMIQ_SVAUNIT_EX_APB_TEST_PROTOCOL_TEST_SUITE_SV

// Unit test suite for those tests which verify protocol SVA
class amiq_svaunit_ex_apb_test_protocol_test_suite extends svaunit_test_suite;
   `uvm_component_utils(amiq_svaunit_ex_apb_test_protocol_test_suite)

   // Number of protocol_test11 tests
   local int unsigned nof_tests_ut11;

   /* Constructor for amiq_svaunit_ex_apb_test_protocol_test_suite
    * @param name   : instance name for amiq_svaunit_ex_apb_test_protocol_test_suite object
    * @param parent : hierarchical parent for amiq_svaunit_ex_apb_test_protocol_test_suite
    */
   function new(input string name = "amiq_svaunit_ex_apb_test_protocol_test_suite", input uvm_component parent);
      super.new(name, parent);
   endfunction

   /* Build phase method used to instantiate components
    * @param phase : the phase scheduled for build_phase method
    */
   virtual function void build_phase(input uvm_phase phase);
      super.build_phase(phase);

      if(!randomize(nof_tests_ut11) with {nof_tests_ut11 inside {[3: 10]};}) begin
         `uvm_error("SVAUNIT_TEST_SUITE_RANDOMIZE_ERR",
            $sformatf("Could not randomize the nof_tests_ut11 from %s", get_test_name()))
      end


      // Register tests into test-suite
      `add_test(amiq_svaunit_ex_apb_test_illegal_sel_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_sel_trans_during_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_sel_min_time#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_en_fall#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_sign_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_en_assertion#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_en_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_en_val#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_en_deassertion#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_strb_val_read_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_svlerr_cond#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_rdata_trans#(10))
      `add_test(amiq_svaunit_ex_apb_test_illegal_sel_val)

      for(int idx = 0; idx < nof_tests_ut11; idx++) begin
         `add_test(amiq_svaunit_ex_apb_test_illegal_ready_max_low_time#(10))
      end
   endfunction
endclass

`endif

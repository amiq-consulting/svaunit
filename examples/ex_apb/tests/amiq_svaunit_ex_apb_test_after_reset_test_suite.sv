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
 * NAME:        amiq_svaunit_ex_apb_test_after_reset_test_suite.sv
 * PROJECT:     svaunit
 * Description: Unit test suite for those tests which verify after reset SVA
 *******************************************************************************/

`ifndef AMIQ_SVAUNIT_EX_APB_TEST_AFTER_RESET_TEST_SUITE_SV
`define AMIQ_SVAUNIT_EX_APB_TEST_AFTER_RESET_TEST_SUITE_SV

// Unit test suite for those tests which verify after reset SVA
class amiq_svaunit_ex_apb_test_after_reset_test_suite extends svaunit_test_suite;
   `uvm_component_utils(amiq_svaunit_ex_apb_test_after_reset_test_suite)

   /* Constructor for amiq_svaunit_ex_apb_test_after_reset_test_suite
    * @param name   : instance name for amiq_svaunit_ex_apb_test_after_reset_test_suite object
    * @param parent : hierarchical parent for amiq_svaunit_ex_apb_test_after_reset_test_suite
    */
   function new(input string name = "amiq_svaunit_ex_apb_test_after_reset_test_suite", input uvm_component parent);
      super.new(name, parent);
   endfunction

   /* Build phase method used to instantiate components
    * @param phase : the phase scheduled for build_phase method
    */
   virtual function void build_phase(input uvm_phase phase);
      super.build_phase(phase);

      // Register unit tests to test suite
      `add_test(amiq_svaunit_ex_apb_test_after_reset_enable#(10, 10))
      `add_test(amiq_svaunit_ex_apb_test_after_reset_enable#(10))
      `add_test(amiq_svaunit_ex_apb_test_after_reset_slverr#(10))
      `add_test(amiq_svaunit_ex_apb_test_after_reset_sel#(10))
      `add_test(amiq_svaunit_ex_apb_test_x_z_test_suite)
   endfunction
endclass

`endif

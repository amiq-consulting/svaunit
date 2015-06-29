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
 * NAME:        amiq_svaunit_ex_apb_test_pkg.sv
 * PROJECT:     svaunit
 * Description: Package with all SVAUnit tests for APB
 *******************************************************************************/

`ifndef AMIQ_SVAUNIT_EX_APB_TEST_PKG_SV
`define AMIQ_SVAUNIT_EX_APB_TEST_PKG_SV

`include "amiq_apb_if.sv"

// Package with all tests for SVA after reset
package amiq_svaunit_ex_apb_test_pkg;
   import svaunit_pkg::*;
   import uvm_pkg::*;
`include "uvm_macros.svh"

`include  "amiq_svaunit_ex_apb_test_x_z_addr.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_enable.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_prot.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_ready.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_sel.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_slverr.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_strb.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_write.sv"
`include  "amiq_svaunit_ex_apb_test_x_z_test_suite.sv"

`include  "amiq_svaunit_ex_apb_test_after_reset_enable.sv"
`include  "amiq_svaunit_ex_apb_test_after_reset_sel.sv"
`include  "amiq_svaunit_ex_apb_test_after_reset_slverr.sv"
`include  "amiq_svaunit_ex_apb_test_after_reset_test_suite.sv"

`include  "amiq_svaunit_ex_apb_test_illegal_sel_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_sel_trans_during_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_sel_min_time.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_en_fall.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_sign_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_en_assertion.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_en_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_en_val.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_en_deassertion.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_strb_val_read_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_ready_max_low_time.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_rdata_trans.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_svlerr_cond.sv"
`include  "amiq_svaunit_ex_apb_test_illegal_sel_val.sv"
`include  "amiq_svaunit_ex_apb_test_protocol_test_suite.sv"

`include  "amiq_svaunit_ex_apb_test_suite.sv"
endpackage

`endif

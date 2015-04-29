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
 * NAME:        apb_tests_pkg.sv
 * PROJECT:     svaunit
 * Description: Package with all SVAUnit tests for APB
 *******************************************************************************/

`ifndef __APB_TESTS_PKG_SV
//protection against multiple includes
`define __APB_TESTS_PKG_SV

`include "amiq_apb_if.sv"

// Package with all tests for SVA after reset
package apb_tests_pkg;
    import svaunit_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include  "x_z_addr_ut.sv"
    `include  "x_z_enable_ut.sv"
    `include  "x_z_prot_ut.sv"
    `include  "x_z_ready_ut.sv"
    `include  "x_z_sel_ut.sv"
    `include  "x_z_slverr_ut.sv"
    `include  "x_z_strb_ut.sv"
    `include  "x_z_write_ut.sv"
    `include  "x_z_ts.sv"

    `include  "after_reset_enable_ut.sv"
    `include  "after_reset_sel_ut.sv"
    `include  "after_reset_slverr_ut.sv"
    `include  "after_reset_ts.sv"

    `include  "protocol_ut1.sv"
    `include  "protocol_ut2.sv"
    `include  "protocol_ut3.sv"
    `include  "protocol_ut4.sv"
    `include  "protocol_ut5.sv"
    `include  "protocol_ut6.sv"
    `include  "protocol_ut7.sv"
    `include  "protocol_ut8.sv"
    `include  "protocol_ut9.sv"
    `include  "protocol_ut10.sv"
    `include  "protocol_ut11.sv"
    `include  "protocol_ut12.sv"
    `include  "protocol_ut13.sv"
    `include  "protocol_ut14.sv"
    `include  "protocol_ts.sv"
    
    `include  "apb_ts.sv"
endpackage

`endif

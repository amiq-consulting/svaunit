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
 * NAME:        top.sv
 * PROJECT:     svaunit
 * Description: Top for a simple example with an SVA
 *******************************************************************************/

`ifndef __TOP_SV
//protection against multiple includes
`define __TOP_SV

`include "simple_pkg.sv"

// Top for a simple example with an SVA
module top;
    // Enable SVAUNIT
    `SVAUNIT_UTILS
    
    import simple_pkg::*;
    
    // an_interface clock
    reg clock;

    // an_interface instance
    an_interface an_if(.clk(clock));

    initial begin
        // Register a reference to the virtual interface to config_db
        uvm_config_db#(virtual an_interface)::set(uvm_root::get(), "*", "VIF", an_if);
    end

    initial begin
        // Start test specified with UVM_TESTNAME
        run_test();
    end

    // Set clock initial values
    initial begin
        clock = 1'b0;
    end

    // Clock generation
    always #1 clock = ~clock;
endmodule

`endif

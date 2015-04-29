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
 * NAME:        simple_pkg.sv
 * PROJECT:     svaunit
 * Description: Package with a simple example of SVAUnit tests
 *******************************************************************************/

`ifndef __SIMPLE_PKG_SV
//protection against multiple includes
`define __SIMPLE_PKG_SV

`include "an_interface.sv"

package simple_pkg;
    import svaunit_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "ut1.sv"
    `include "ut2.sv"
    `include "uts.sv"
endpackage

`endif

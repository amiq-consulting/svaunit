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
 * NAME:        protocol_ts.sv
 * PROJECT:     svaunit
 * Description: Unit test suite for those tests which verify protocol SVA
 *******************************************************************************/

`ifndef __PROTOCOL_TS_SV
//protection against multiple includes
`define __PROTOCOL_TS_SV

// Unit test suite for those tests which verify protocol SVA
class protocol_ts extends svaunit_test_suite;
    `uvm_component_utils(protocol_ts)

    // Define unit tests for checking protocol SVA
    protocol_ut1#(10)  protocol_test1;
    protocol_ut2#(10)  protocol_test2;
    protocol_ut3#(10)  protocol_test3;
    protocol_ut4#(10)  protocol_test4;
    protocol_ut5#(10)  protocol_test5;
    protocol_ut6#(10)  protocol_test6;
    protocol_ut7#(10)  protocol_test7;
    protocol_ut8#(10)  protocol_test8;
    protocol_ut9#(10)  protocol_test9;
    protocol_ut10#(10) protocol_test10;
    protocol_ut11#(10) protocol_test11[];
    protocol_ut12#(10) protocol_test12;
    protocol_ut13#(10) protocol_test13;
    protocol_ut14 protocol_test14;

    // Number of protocol_test11 tests
    int nof_tests;

    /* Constructor for protocol_ts
     * @param name   : instance name for protocol_ts object
     * @param parent : hierarchical parent for protocol_ts
     */
    function new(input string name = "protocol_ts", input uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Create and instantiate protocol unit tests
        protocol_test1  = protocol_ut1#(10)::type_id::create("protocol_test1", this);
        protocol_test2  = protocol_ut2#(10)::type_id::create("protocol_test2", this);
        protocol_test3  = protocol_ut3#(10)::type_id::create("protocol_test3", this);
        protocol_test4  = protocol_ut4#(10)::type_id::create("protocol_test4", this);
        protocol_test5  = protocol_ut5#(10)::type_id::create("protocol_test5", this);
        protocol_test6  = protocol_ut6#(10)::type_id::create("protocol_test6", this);
        protocol_test7  = protocol_ut7#(10)::type_id::create("protocol_test7", this);
        protocol_test8  = protocol_ut8#(10)::type_id::create("protocol_test8", this);
        protocol_test9  = protocol_ut9#(10)::type_id::create("protocol_test9", this);
        protocol_test10 = protocol_ut10#(10)::type_id::create("protocol_test10", this);
        protocol_test13 = protocol_ut13#(10)::type_id::create("protocol_test13", this);
        protocol_test12 = protocol_ut12#(10)::type_id::create("protocol_test12", this);
        protocol_test14 = protocol_ut14::type_id::create("protocol_test14", this);

        nof_tests = $urandom_range(10, 3);

        for(int i = 0; i < nof_tests; i++) begin
            protocol_test11 = new[protocol_test11.size() + 1] (protocol_test11);
            protocol_test11[i] = protocol_ut11#(10)::type_id::create($sformatf("protocol_ut11_%0d", i), this);
        end

        // Register unit tests to test suite
        add_test(protocol_test1);
        add_test(protocol_test2);
        add_test(protocol_test3);
        add_test(protocol_test4);
        add_test(protocol_test5);
        add_test(protocol_test6);
        add_test(protocol_test7);
        add_test(protocol_test8);
        add_test(protocol_test9);
        add_test(protocol_test10);
        add_test(protocol_test12);
        add_test(protocol_test13);
        add_test(protocol_test14);
        for(int i = 0; i < nof_tests; i++) begin
            add_test(protocol_test11[i]);
        end
    endfunction
endclass

`endif

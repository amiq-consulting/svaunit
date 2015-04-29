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
 * MODULE:       svaunit_base.svh
 * PROJECT:      svaunit
 * Description:  svaunit base class for tests and test suites
 *******************************************************************************/

`ifndef __SVAUNIT_BASE_SVH
//protection against multiple includes
`define __SVAUNIT_BASE_SVH

// svaunit base class for tests and test suites
class svaunit_base extends uvm_test;
    // Shows that the test is enable or disable during simulation
    bit enable;

    `uvm_component_utils_begin(svaunit_base)
        `uvm_field_int(enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // Test status
    svaunit_status_type status;

    // Shows that the test ran or not during a simulation
    bit has_started;

    // Stores the number of immediate assertions which fails during a test
    int unsigned nof_failures;

    // Stores the total number of immediate assertions tested
    int unsigned nof_tests;

    // When this bit is 1, the test should stop
    bit stop;

    // Stores the name of the current test
    string test_name;

    // Stores the type of the current test
    string test_type;

    // Will set the name of the current test
    virtual function void set_test_name();
    endfunction

    /* Will set the name of the current test
     * a test name will look like this : testsuitetop_id.testname
     */
    function void set_name_for_test();
        // Get parent of this test
        uvm_component parent = get_parent();

        if(parent.get_name() == "") begin
            test_name = $sformatf("%s", get_type_name());
        end else begin
            if(parent.get_name() == "uvm_test_top") begin
                test_name = $sformatf("%s.%s", parent.get_type_name(), get_name());
            end else begin
                if(get_name() == "uvm_test_top") begin
                    test_name = $sformatf("%s", get_name());
                end else begin
                    test_name = $sformatf("%s.%s", parent.get_name(), get_name());
                end
            end
        end
    endfunction

    /* Get the name of the test
     * @return the test name
     */
    function string get_test_name();
        return test_name;
    endfunction

    /* Constructor for svaunit_base
     * @param name   : instance name for svaunit_base object
     * @param parent : hierarchical parent for svaunit_base
     */
    function new (string name = "svaunit_base", uvm_component parent);
        super.new(name, parent);

        // Initialize the counters
        nof_failures = 0;
        nof_tests = 0;
        has_started = 0;
        stop = 0;
        enable = 1;
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        set_test_name();
        set_name_for_test();
    endfunction

    // Sets the custom message reporter
    virtual function void start_of_simulation();
        // Create a new reporter server and set as server used
        svaunit_reporter sva_unit_server = new();
        uvm_report_server::set_server(sva_unit_server);
    endfunction

    /* Find the position of the first character of the first match of s2 in s1
     * @param s1 : the string used to search in the s2
     * @param s2 : the string to search for.
     * @return the position of the first character of the first match. If no matches were found, the function will return -1
     */
    function int find(string s1, string s2);
        bit exists = 0;

        if(s1.len() < s2.len()) begin
            return -1;
        end else begin
            if(s1.len() == s2.len()) begin
                return (s1 == s2);
            end
        end

        for (int unsigned char_index = 0; char_index < s1.len() - s2.len(); char_index = char_index + 1) begin
            bit exists = 0;

            for(int unsigned char_s2_index = 0; char_s2_index < s2.len(); char_s2_index = char_s2_index + 1) begin
                if (s1.getc(char_index) != s2.getc(char_s2_index)) begin
                    exists = 1;
                end

                if(exists == 0) begin
                    return char_index;
                end
            end
        end

        return -1;
    endfunction

    /* Get the number of immediate assertions which failed during test
     * @return the number of immediate assertions which failed during test
     */
    function int unsigned get_nof_failures();
        return nof_failures;
    endfunction

    /* Get the number of immediate assertions verified during test
     * @return the number of immediate assertions verified during test
     */
    function int unsigned get_nof_tests();
        return nof_tests;
    endfunction

    // Start test - set has_started bit
    function void start_test();
        has_started = 1;
    endfunction

    /* Get the fact that the test ran or not during simulation
     * @return 1 if the test ran or 0 otherwise
     */
    function bit started();
        return has_started;
    endfunction

    /* Get status of test
     * @return the status of test
     */
    function svaunit_status_type get_status();
        return status;
    endfunction

    /* Get stop bit for test
     * @return the stop bit for test
     */
    function bit get_stop();
        return stop;
    endfunction

    // Update status
    virtual function void update_status();
        int unsigned nof_tests_did_not_run = 0;

        nof_tests_did_not_run = get_nof_tests_did_not_run();

        // If no failure have been found, the test will PASS and it's status is PASSED 
        // If some failure have been found, the test will FAIL and it's status is FAILED 
        // if the test did not run, it's status is DID_NOT_RUN
        if(nof_failures == 0) begin
            if((nof_tests == 0) || (nof_tests_did_not_run == nof_tests)) begin
                status = SVAUNIT_DID_NOT_RUN;
            end else begin
                status = SVAUNIT_PASS;
            end
        end else begin
            status = SVAUNIT_FAIL;
        end
    endfunction

    /* Compute the number of tests from current test suite which did not run
     * @return the number of tests from current test suite which did not run
     */
    virtual function int unsigned get_nof_tests_did_not_run();
        return 0;
    endfunction

    // {{{ Functions used for immediate assertions
    /* Get a list with names for all immediate assertion used
     * @param the string list which contains the name of the checks used in this unit test
     */
    virtual function void get_immediate_assertion_names(ref string immediate_assertions_names[$]);
    endfunction

    /* Get a list with names for all immediate assertion not used
     * @param the string list which contains the name of the checks not used in this unit test
     */
    virtual function void get_immediate_assertion_not_used_names(ref string immediate_assertions_names[$]);
    endfunction

    /* Get the number of times an immediate assertion was tested during simulation
     * @return the number of times an immediate assertion was tested during simulation
     */
    virtual function int unsigned get_nof_times_immediate_assertions_tested(string immediate_assertion_name);
        return 0;
    endfunction

    /* Get the number of times an immediate assertion passed during simulation
     * @return the number of times an immediate assertion passed during simulation
     */
    virtual function int unsigned get_nof_times_immediate_assertions_passed(string immediate_assertion_name);
        return 0;
    endfunction
    // }}}

    // {{{ Print functions
    // Print status of test
    virtual function void print_status();
    endfunction

    // Print a list with all SVAs
    virtual function void print_sva();
    endfunction

    // Print a report for all checks tested for the current unit test
    virtual function void print_checks();
    endfunction

    // Print a report for all checks tested for the SVAs
    virtual function void print_sva_and_checks();
    endfunction

    // Method used to print the final report
    virtual function void print_report();
    endfunction
// }}}
endclass

`endif

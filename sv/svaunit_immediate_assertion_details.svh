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
 * MODULE:       svaunit_immediate_assertion_details.svh
 * PROJECT:      svaunit
 * Description:  Immediate assertion details class - it contains the name, the tested time and the status
 *******************************************************************************/

`ifndef __SVAUNIT_IMMEDIATE_ASSERTION_DETAILS_SVH
//protection against multiple includes
`define __SVAUNIT_IMMEDIATE_ASSERTION_DETAILS_SVH

// Immediate assertion details class - it contains the name, the tested time and the status
class svaunit_immediate_assertion_details extends uvm_object;
    `uvm_object_utils(svaunit_immediate_assertion_details)

    // Will store the name of the immediate assertion tested into current test
    local string immediate_assertion_name;

    // Will store the time at which the immediate assertion is executed
    time immediate_assertion_time[$];

    // Will store the status of the immediate assertion
    svaunit_status_type immediate_assertions_status[$];

    /* Constructor for an svaunit_immediate_assertion_details
     * @param name : instance name for svaunit_immediate_assertion_details object
     */
    function new(input string name = "svaunit_immediate_assertion_details");
        super.new(name);
    endfunction

    /* Set immediate assertion name
     * @param immediate_assertion : current immediate_assertion name to be added
     */
    function void set_immediate_assertion_name(string immediate_assertion);
        immediate_assertion_name = immediate_assertion;
    endfunction

    /* Get immediate assertion name
     * @return the immediate assertion name
     */
    function string get_immediate_assertion_name();
        return immediate_assertion_name;
    endfunction

    /* Add test time for the immediate assertion
     * @param crt_immediate_assertion_test_time : current time when the immediate assertion was tested
     */
    function void add_immediate_assertion_test_time(time crt_immediate_assertion_test_time);
        immediate_assertion_time.push_back(crt_immediate_assertion_test_time);
    endfunction

    /* Add status for the immediate assertion
     * @param crt_immediate_assertion_status : status of the current attempt of immediate assertion
     */
    function void add_immediate_assertion_status(svaunit_status_type crt_immediate_assertion_status);
        immediate_assertions_status.push_back(crt_immediate_assertion_status);
    endfunction

    /* Create new details for the immediate assertion : set name, the test time and the status for the current attempt of the immediate assertion
     * @param immediate_assertion : the name of immediate assertion which is tested
     * @param test_time : the time at which the immediate assertion was tested
     * @param status : the current status of the immediate assertion
     */
    function void create_new_detail_immediat_assertion(string immediate_assertion, time test_time, svaunit_status_type status);
        set_immediate_assertion_name(immediate_assertion);
        add_immediate_assertion_test_time(test_time);
        add_immediate_assertion_status(status);
    endfunction

    /* Add new details for the immediate assertion : set test time and status for the current attempt of the immediate assertion
     * @param test_time : the time at which the immediate assertion was tested
     * @param status : the current status of the immediate assertion
     */
    function void add_new_detail(time test_time, svaunit_status_type status);
        add_immediate_assertion_test_time(test_time);
        add_immediate_assertion_status(status);
    endfunction

    /* Compute the number of times the immediate assertion passed during simulation
     * @return the number of times the immediate assertion passed during simulation
     */
    function int unsigned get_nof_times_immediate_assertion_pass();
        // Variable used to store the number of times the immediate assertion passed during simulation
        int unsigned nof_times_immediate_assertion_pass = 0;

        // Check for each immediate assertion if they passed and increase the counter
        foreach(immediate_assertions_status[status_index]) begin
            if(immediate_assertions_status[status_index] == SVAUNIT_PASS) begin
                nof_times_immediate_assertion_pass = nof_times_immediate_assertion_pass + 1;
            end
        end

        // Return the number of times the immediate assertion passed during simulation
        return nof_times_immediate_assertion_pass;
    endfunction

    /* Compute the number of times the immediate assertion was tested during simulation
     * @return the number of times the immediate assertion was tested during simulation
     */
    function int unsigned get_nof_times_immediate_assertion_tested();
        return immediate_assertions_status.size();
    endfunction

    /* Get details for a immediate assertion
     * @return a string with all immediate assertion details
     */
    function string get_immediate_assertion_detail();
        string star = " ";

        if(get_nof_times_immediate_assertion_pass() < get_nof_times_immediate_assertion_tested()) begin
            star = "*";
        end

        return $sformatf("%s   %s %0d/%0d times PASSED", star, immediate_assertion_name, get_nof_times_immediate_assertion_pass(), get_nof_times_immediate_assertion_tested());
    endfunction

    // Function used to copy the current item into new item
    function svaunit_immediate_assertion_details copy();
        copy = svaunit_immediate_assertion_details::type_id::create("copy_svaunit_immediate_assertion_details");

        copy.immediate_assertion_name = this.immediate_assertion_name;

        foreach(this.immediate_assertion_time[index]) begin
            copy.immediate_assertion_time.push_back(this.immediate_assertion_time[index]);
        end

        foreach(this.immediate_assertions_status[index]) begin
            copy.immediate_assertions_status.push_back(this.immediate_assertions_status[index]);
        end
    endfunction
endclass

`endif

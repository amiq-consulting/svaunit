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
 * MODULE:       svaunit_concurrent_assertion_details.svh
 * PROJECT:      svaunit
 * Description:  SVA details class - it contains the states, the start time, the end time for the current attempt of SVA 
 *               and the test name where the SVA was tested
 *******************************************************************************/

`ifndef __SVAUNIT_CONCURRENT_ASSERTION_DETAILS_SVH
//protection against multiple includes
`define __SVAUNIT_CONCURRENT_ASSERTION_DETAILS_SVH

// SVA details class - it contains SVA start time, SVA end time, the states and the test where the SVA was tested
class svaunit_concurrent_assertion_details extends uvm_object;
    `uvm_object_utils(svaunit_concurrent_assertion_details)

    // Start time of the current SVA attempt
    local time sva_start_time;

    // End time of the current SVA attempt
    local time sva_end_time;

    // List of state - should have only 2 states: start state and end state
    local svaunit_concurrent_assertion_state_type sva_states[$];

    // Test name where this attempt was found
    local string test_name;

    /* Constructor for an svaunit_concurrent_assertion_details
     * @param name   : instance name for svaunit_concurrent_assertion_details object
     */
    function new(string name = "svaunit_concurrent_assertion_details");
        super.new(name);
    endfunction

    /* Create new detail for an SVA
     * @param crt_test_name : test name where this attempt was found
     * @param sva_state : SVA state to be added
     * @param sva_time_start : SVA start time to be added
     * @param sva_time_end : SVA end time to be added
     */
    function void create_new_detail(string crt_test_name, svaunit_concurrent_assertion_state_type sva_state, time sva_time_start, time sva_time_end);
        // Add new state inside list
        add_sva_state(sva_state);
        set_sva_start_time(sva_time_start);
        set_sva_test_name(crt_test_name);

        // If state is DISABLE, ENABLE, IDLE or START, the end time should be 0 else it should be sva_time_end given
        if(sva_state inside {SVAUNIT_DISABLE, SVAUNIT_ENABLE, SVAUNIT_IDLE, SVAUNIT_START}) begin
            sva_end_time = 0;
        end else begin
            set_sva_end_time(sva_time_end);
        end
    endfunction

    /* Set test name for the current attempt of SVA
     * @param crt_test_name
     */
    function void set_sva_test_name(string crt_test_name);
        test_name = crt_test_name;
    endfunction

    /* Set start time for the current attempt of SVA
     * @param crt_sva_start_time : current start time
     */
    function void set_sva_start_time(time crt_sva_start_time);
        sva_start_time = crt_sva_start_time;
    endfunction

    /* Get the start time of the current SVA attempt
     * @return the start time of the current SVA attempt
     */
    function time get_sva_start_time();
        return sva_start_time;
    endfunction

    /* Set end time for the current attempt of SVA
     *@param crt_sva_end_time : current end time
     */
    function void set_sva_end_time(time crt_sva_end_time);
        sva_end_time = crt_sva_end_time;
    endfunction

    /* Get the end time of the current SVA attempt
     * @return the end time of the current SVA attempt
     */
    function time get_sva_end_time();
        return sva_end_time;
    endfunction

    /* Get the first state of the current attempt of the SVA
     * @return the first state of the current attempt of the SVA
     */
    function svaunit_concurrent_assertion_state_type get_sva_first_state();
        return sva_states[`SVAUNIT_START_STATE_INDEX];
    endfunction

    /* Add end state for the current attempt of the assertion
     * @param end_state : SVA state to be added
     */
    function void add_sva_state(svaunit_concurrent_assertion_state_type end_state);
        // If the end_state is START or IDLE it should be at the first index
        if(end_state inside {SVAUNIT_START, SVAUNIT_IDLE}) begin
            sva_states.push_front(end_state);
        end else begin
            sva_states.push_back(end_state);
        end
    endfunction

    /* Get the end state of the current attempt of the SVA
     * @return the end state of the current attempt of the SVA
     */
    function svaunit_concurrent_assertion_state_type get_sva_last_state();
        return sva_states[`SVAUNIT_END_STATE_INDEX];
    endfunction

    /* Verify if the current SVA is not finished
     * @return 1 if SVA has not finished and 0 otherwise
     */
    function bit sva_is_not_finished();
        if(((sva_end_time == 0) && (get_sva_first_state() == SVAUNIT_START)) || (get_sva_first_state() inside {SVAUNIT_FAILURE, SVAUNIT_SUCCESS} && sva_states.size() == 1)) begin
            return 1;
        end else begin
            return 0;
        end
    endfunction

    /* Verify if the current SVA attempt is finished
     * @return 1 if SVA has finished and 0 otherwise
     */
    function bit sva_is_finished();
        return !sva_is_not_finished();
    endfunction

    /* Verify if current SVA attempt has failed - one of it's state should be FAILURE
     * @return 1 if SVA attempt has failed or 0 otherwise
     */
    function bit sva_failed();
        // Verify if SVA has finished and check if the last state is FAILURE
        if(sva_is_finished()) begin
            if(get_sva_last_state() == SVAUNIT_FAILURE) begin
                return 1;
            end
        end

        return 0;
    endfunction

    /* Verify if current SVA attempt has succeeded - one of it's state should be SUCCESS
     * @return 1 if SVA attempt has finished with success or 0 otherwise
     */
    function bit sva_succeeded();
        // Verify if SVA has finished and check if the last state is SUCCESS
        if(sva_is_finished()) begin
            if(get_sva_last_state() == SVAUNIT_SUCCESS) begin
                return 1;
            end
        end

        return 0;
    endfunction

    /* Verify if current SVA attempt has started - the first state should be START
     * @return 1 if SVA attempt has started or 0 otherwise
     */
    function bit sva_started();
        if(get_sva_first_state() == SVAUNIT_START) begin
            return 1;
        end

        return 0;
    endfunction

    /* Verify if current SVA attempt has started but has not finished
     * @return 1 if SVA attempt has started but has not finished or 0 otherwise
     */
    function bit sva_has_started_but_has_not_finished();
        // Verify if SVA has not finished but has finished
        if(sva_is_not_finished()) begin
            if(sva_started()) begin
                return 1;
            end
        end

        return 0;
    endfunction

    /* Verify if the first state is not START
     * @return 1 if the first state of the current SVA attempt is not START or 0 otherwise
     */
    function bit sva_first_state_not_start();
        if(get_sva_first_state() != SVAUNIT_START) begin
            return 1;
        end

        return 0;
    endfunction

    /* Print the SVA details for a given test name
     * @param crt_test_name : test name from where the user want's to print SVA info
     * @return a string with all SVA details
     */
    function string get_sva_details(string crt_test_name);
        // Stores the states names as a string
        string states;

        // Compute the string with states, start time and end time
        // Example:
        // states : START SUCCESS,
        // start time: 3,
        // end time: 3
        if(crt_test_name == test_name) begin
            // Form the state name
            foreach(sva_states[index]) begin
                states = $sformatf("%s %s", states, sva_states[index].name());
            end

            return $sformatf("\nstates :%s,\nstart time: %0d,\nend time: %0d\n", states, sva_start_time, sva_end_time);
        end else begin
            return "";
        end
    endfunction
endclass

`endif

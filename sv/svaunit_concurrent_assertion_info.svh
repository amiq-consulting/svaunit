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
 * MODULE:       svaunit_concurrent_assertion_info.svh
 * PROJECT:      svaunit
 * Description:  SVA info class - it contains the SVA name, the SVA type, if SVA was enabled during test,
 *                                if it was tested, a list of details and coverage counters
 *******************************************************************************/

`ifndef __SVAUNIT_CONCURRENT_ASSERTION_INFO_SVH
//protection against multiple includes
`define __SVAUNIT_CONCURRENT_ASSERTION_INFO_SVH

// SVA info class - it contains the SVA name, the SVA type
//                  if SVA was enabled during test,
//                  if it was tested, a list of details and coverage counters
class svaunit_concurrent_assertion_info extends uvm_object;
    // Shows that an SVA is enable or not during test
    local bit enable;

    `uvm_object_utils_begin(svaunit_concurrent_assertion_info)
        `uvm_field_int(enable, UVM_DEFAULT)
    `uvm_object_utils_end

    // SVA name
    local string sva_name;

    // SVA type
    local string sva_type;

    // Shows that an SVA was tested or not during test
    local svaunit_sva_tested_type tested;

    // List of details for the SVA
    local svaunit_concurrent_assertion_details sva_details[];

    // Counter used to store the number of failures for an SVA cover
    local int nof_attempts_failed_covered;

    // Counter used to store the number of successful attempts for an SVA cover
    local int nof_attempts_successfull_covered;

    // List of tests names where current SVA is enabled
    local string lof_tests_enabled_sva[$];

    // List of tests names where current SVA is tested
    local string lof_tests_tested_sva[$];

    /* Constructor for an svaunit_concurrent_assertion_info
     * @param name : instance name for svaunit_concurrent_assertion_info object
     */
    function new(string name = "svaunit_concurrent_assertion_info");
        super.new(name);

        // Initial the enable bit is 1
        enable = 1;
    endfunction

    /* Create new SVA - the first detail is IDLE (the start and end time are the current time)
     * @param crt_sva_name : current name to initialize the new SVA
     * @param crt_sva_type : current type to initialize the new SVA
     */
    function void create_new_sva(string crt_sva_name, string crt_sva_type);
        // Initialize SVA : set name, type, IDLE state and end time
        sva_name = crt_sva_name;
        sva_type = crt_sva_type;

        // Initial the enable bit is 1
        enable = 1;
        add_new_detail_sva("", SVAUNIT_IDLE, $time(), $time());
    endfunction

    /* Add new SVA details
     * @param crt_test_name : test name where this attempt was found
     * @param crt_sva_state : SVA state to be added
     * @param crt_sva_start_time : SVA start time to be added
     * @param crt_sva_end_time : SVA end time to be added
     */
    function void add_new_detail_sva(string crt_test_name, svaunit_concurrent_assertion_state_type crt_sva_state, time crt_sva_start_time, time crt_sva_end_time);
        // Increase the SVA details list size
        sva_details = new[sva_details.size() + 1](sva_details);

        // Create a new detail using factory mechanism
        sva_details[sva_details.size() - 1] = svaunit_concurrent_assertion_details::type_id::create($sformatf("%s_detail_%s", sva_name, sva_details.size() - 1));

        // Create new detail using given arguments
        sva_details[sva_details.size() - 1].create_new_detail(crt_test_name, crt_sva_state, crt_sva_start_time, crt_sva_end_time);
    endfunction

    /* Update detail for current SVA attempt if there it was an attempt at given start time, add end time and current state 
     * else add new detail to SVA info
     * @param crt_test_name : test name where this attempt was found
     * @param crt_sva_start_time : SVA start time
     * @param crt_sva_state : SVA state
     * @param crt_sva_end_time : SVA end time
     */
    function void update_details(string crt_test_name, time crt_sva_start_time, time crt_sva_end_time, svaunit_concurrent_assertion_state_type crt_sva_state);
        // Variable used to show that it it was an SVA attempt at given start time
        bit exists = 1'b0;

        // For each SVA details verify if it was an SVA attempt at given time
        // if the current state is ENABLE or DISABLE a new detail should be created
        foreach(sva_details[index]) begin
            if(exists == 1'b0) begin
                if((sva_details[index].get_sva_start_time() == crt_sva_start_time) && !(crt_sva_state inside {SVAUNIT_ENABLE, SVAUNIT_DISABLE})) begin
                    // If current state is START and the first state of details is START, ENABLE, DISABLE or IDLE add new detail else update the detail
                    if(!(crt_sva_state == SVAUNIT_START && sva_details[index].get_sva_first_state() inside {SVAUNIT_START, SVAUNIT_ENABLE, SVAUNIT_DISABLE, SVAUNIT_IDLE})) begin
                        sva_details[index].add_sva_state(crt_sva_state);
                        sva_details[index].set_sva_end_time(crt_sva_end_time);

                        exists = 1;
                    end
                end
            end
        end

        // Create new detail if there was not a proper detail
        if((crt_sva_state inside {SVAUNIT_ENABLE, SVAUNIT_DISABLE}) || (exists == 1'b0)) begin
            add_new_detail_sva(crt_test_name, crt_sva_state, crt_sva_start_time, crt_sva_end_time);
        end
    endfunction

    /* Get the index of the last SVA detail which has finished
     * @return the index of the last SVA detail which has finished
     */
    function int unsigned get_last_index_sva_finished();
        // Variable used to store the last index
        int unsigned last_index = 0;

        // Verify for all details if they finished and store the last index of finished detail
        foreach(sva_details[index]) begin
            if(!(sva_details[index].sva_is_not_finished())) begin
                last_index = index;
            end
        end

        // Return the last index
        return last_index;
    endfunction

    /* Get the first state of the last SVA detail
     * @return the first state of the last SVA detail
     */
    function svaunit_concurrent_assertion_state_type get_sva_first_state();
        return sva_details[sva_details.size() - 1].get_sva_first_state();
    endfunction

    /* Get the last state of the last SVA detail which has finished
     * @return the last state of the last SVA detail which has finished
     */
    function svaunit_concurrent_assertion_state_type get_sva_last_state();
        // Variable used to store the last index of the SVA which has finished
        int unsigned last_index_assertion_finished = get_last_index_sva_finished();

        if(sva_details.size() > 0) begin
            return sva_details[last_index_assertion_finished].get_sva_last_state();
        end else begin
            return svaunit_concurrent_assertion_state_type'(0);
        end
    endfunction

    /* Verify if last SVA has finished
     * @return 1 if last SVA has finished, 0 otherwise
     */
    function bit sva_is_finished();
        if(sva_details.size() > 0) begin
            return sva_details[sva_details.size() - 1].sva_is_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify if last SVA has not finished
     * @return 1 if last SVA has not finished, 0 otherwise
     */
    function bit sva_is_not_finished();
        if(sva_details.size() > 0) begin
            return sva_details[sva_details.size() - 1].sva_is_not_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify if the last SVA detail started but has not finished
     * @return 1 if the last SVA detail started but has not finished and 0 otherwise
     */
    function bit sva_has_started_but_has_not_finished();
        if(sva_details.size() > 0) begin
            return sva_details[sva_details.size() - 1].sva_has_started_but_has_not_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify if the last SVA detail succeeded
     * @return 1 if the last SVA detail succeeded and 0 otherwise
     */
    function bit sva_succeeded();
        // Variable used to store the last index which has finished
        int unsigned last_index_assertion_finished = get_last_index_sva_finished();

        if(sva_details.size() > 0) begin
            return sva_details[last_index_assertion_finished].sva_succeeded();
        end else begin
            return 0;
        end
    endfunction

    /* Verify if the last SVA detail failed
     * @return 1 if the last SVA detail failed and 0 otherwise
     */
    function bit sva_failed();
        // Variable used to store the last index which has finished
        int unsigned last_index_assertion_finished = get_last_index_sva_finished();

        if(sva_details.size() > 0) begin
            return sva_details[last_index_assertion_finished].sva_failed();
        end else begin
            return 0;
        end
    endfunction

    /* Verify if the first state of the last SVA detail is not START
     * @return 1 if the first state of the last SVA detail is not START and 0 otherwise
     */
    function bit sva_first_state_not_start();
        return sva_details[sva_details.size() - 1].sva_first_state_not_start();
    endfunction

    /* Compute the number of SVA details which not finished
     * @return the number of SVA details which are not finished
     */
    function int unsigned get_nof_incomplete_sva_details();
        // Variable used to store the number of incomplete details
        int unsigned nof_incomplete_sva_details = 0;

        // Verify if details are not finished and increase the counter
        foreach(sva_details[index]) begin
            if(sva_details[index].sva_is_not_finished()) begin
                nof_incomplete_sva_details = nof_incomplete_sva_details + 1;
            end
        end

        // Return the number of incomplete details
        return nof_incomplete_sva_details;
    endfunction

    /* Compute the number of SVA details which contains FAILURE in it's state list
     * @return the number of SVA details which failed
     */
    function int unsigned get_nof_times_sva_fails();
        // Variable used to store the number of details which contains FAILURE in it's state list
        int unsigned nof_times_sva_fails = 0;

        // Verify if details failed and increase the counter
        foreach(sva_details[index]) begin
            if(sva_details[index].sva_failed()) begin
                nof_times_sva_fails = nof_times_sva_fails + 1;
            end
        end

        // Return the number of details which contains FAILURE in it's state list
        return nof_times_sva_fails;
    endfunction

    /* Compute the number of SVA details which contains SUCCESS in it's state list
     * @return the number of SVA details which succeeded
     */
    function int unsigned get_nof_times_sva_succeeded();
        // Variable used to store the number of details which contains SUCCESS in it's state list
        int unsigned nof_times_sva_succeeded = 0;

        // Verify if details succeeded and increase the counter
        foreach(sva_details[index]) begin
            if(sva_details[index].sva_succeeded()) begin
                nof_times_sva_succeeded = nof_times_sva_succeeded + 1;
            end
        end

        // Return the number of details which contains SUCCESS in it's state list
        return nof_times_sva_succeeded;
    endfunction

    /* Compute the number of SVA details which STARTED
     * @return the number of details which started
     */
    function int unsigned get_nof_times_sva_started();
        // Variable used to store the number of details which STARTED
        int unsigned nof_times_sva_started = 0;

        // Verify if details started and increase the counter
        foreach(sva_details[index]) begin
            if(sva_details[index].sva_started()) begin
                nof_times_sva_started = nof_times_sva_started + 1;
            end
        end

        // Return the number of details which STARTED
        return nof_times_sva_started;
    endfunction

    /* Get SVA name
     * @return SVA name
     */
    function string get_sva_name();
        return sva_name;
    endfunction

    /* Get SVA type
     * @return SVA type
     */
    function string get_sva_type();
        return sva_type;
    endfunction

    /* Set the enable bit with a given bit
     * @param test_name : the test name where the assertion have been tested
     * @param enable_bit : current enable bit to set
     */
    function void set_enable(string test_name, bit enable_bit);
        enable = enable_bit;

        if(enable_bit) begin
            lof_tests_enabled_sva.push_back(test_name);
        end
    endfunction

    /* Get the enable bit - it shows that the SVA is enable during test
     * @param test_name : the test name where the assertion have been tested
     * @return SVA status - if it is enabled or not
     */
    function bit is_enable(string test_name);
        if(get_sva_type() != "vpiCover") begin
            foreach(lof_tests_enabled_sva[test_index]) begin
                if(lof_tests_enabled_sva[test_index] == test_name) begin
                    return enable;
                end
            end
        end else begin
            return enable;
        end

        return 0;
    endfunction

    /* Verify if the SVA was enabled during test
     * @param test_name : the test name where the assertion have been tested
     * @return 1 if the SVA was enabled in given test and 0 otherwise
     */
    function bit was_enable(string test_name);
        foreach(lof_tests_enabled_sva[test_index]) begin
            if(lof_tests_enabled_sva[test_index] == test_name) begin
                return 1;
            end
        end

        return 0;
    endfunction

    /* Set the tested bit with 1
     * @param test_name : the test name where the assertion have been tested
     */
    function void set_tested(string test_name);
        tested = SVAUNIT_WAS_TESTED;

        lof_tests_tested_sva.push_back(test_name);
    endfunction

    /* Get the tested bit - it shows that the SVA was tested during test
     * @param test_name : the test name where the assertion have been tested
     * @return SVA status - if it is tested or not
     */
    function svaunit_sva_tested_type was_tested(string test_name);
        if(lof_tests_tested_sva.size() > 0) begin
            foreach(lof_tests_tested_sva[test_index]) begin
                if(lof_tests_tested_sva[test_index] == test_name) begin
                    return tested;
                end
            end
        end

        return SVAUNIT_NOT_TESTED;
    endfunction

    /* Sets the nof_attempts_failed_covered counter with the given number
     * @param crt_nof_attempts_failed_covered : current number to set the counter
     */
    function void set_nof_attempts_failed_covered(int crt_nof_attempts_failed_covered);
        // If crt_nof_attempts_failed_covered is (-1) the counter will be 0, otherwise it will have crt_nof_attempts_failed_covered value
        if(crt_nof_attempts_failed_covered == (-1)) begin
            nof_attempts_failed_covered = 0;
        end else begin
            nof_attempts_failed_covered = crt_nof_attempts_failed_covered;
        end
    endfunction

    /* Get the number of failures for an SVA cover
     * @return the nof_attempts_failed_covered counter
     */
    function int unsigned get_nof_attempts_failed_covered();
        return nof_attempts_failed_covered;
    endfunction

    /* Sets the nof_attempts_successfull_covered counter with the given number
     * @param crt_nof_attempts_successfull_covered : current number to set the counter
     */
    function void set_nof_attempts_successfull_covered(int crt_nof_attempts_successfull_covered);
        // If crt_nof_attempts_successfull_covered is (-1) the counter will be 0, otherwise it will have crt_nof_attempts_successfull_covered value
        if(crt_nof_attempts_successfull_covered == (-1)) begin
            nof_attempts_successfull_covered = 0;
        end else begin
            nof_attempts_successfull_covered = crt_nof_attempts_successfull_covered;
        end
    endfunction

    /* Get the number of successful attempts for an SVA cover
     * @return the nof_attempts_successfull_covered counter
     */
    function int unsigned get_nof_attempts_successful_covered();
        return nof_attempts_successfull_covered;
    endfunction

    /* Print SVA info for a given test
     * @param crt_test_name : test name from where the user want's to print SVA info
     */
    function void print_sva_info(string crt_test_name);
        // Variable used to store the details as a string
        string details;

        // Example:
        // UVM_INFO @ 25000 ns [svaunit_concurrent_assertion_info]: SVA name = AN_SVA
        // UVM_INFO @ 25000 ns [svaunit_concurrent_assertion_info]: SVA type = vpiAssert
        // UVM_INFO @ 25000 ns [svaunit_concurrent_assertion_info]: SVA details[0] =
        // states : IDLE,
        // start time: 0,
        // end time: 0

        `uvm_info(get_name(), $sformatf("SVA name = %s", get_sva_name()), UVM_LOW);
        `uvm_info(get_name(), $sformatf("SVA type = %s", get_sva_type()), UVM_LOW);
        
        foreach(sva_details[index]) begin
            details = sva_details[index].get_sva_details(crt_test_name);
            if(details != "") begin
                `uvm_info(get_name(), $sformatf("[%s] SVA details[%0d] = %s", sva_details[index].get_name(), index, details), UVM_LOW);
            end
        end
    endfunction
endclass

`endif

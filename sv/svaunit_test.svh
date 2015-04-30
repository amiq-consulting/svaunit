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
 * MODULE:       svaunit_test.svh
 * PROJECT:      svaunit
 * Description:  svaunit test class
 *******************************************************************************/

`ifndef __SVAUNIT_TEST_SVH
//protection against multiple includes
`define __SVAUNIT_TEST_SVH

// svaunit test class
virtual class svaunit_test extends svaunit_base;
    // Timeout variable - the test will finished if time reaches this timeout
    time timeout = 10us;

    // Pointer to VPI interface with SVAs, imports and exports to VPI API
    virtual svaunit_vpi_interface vpi_vif;

    // List of immediate assertions tested during a specific test
    svaunit_immediate_assertion_info immediate_assertions[$];

    // List of string which represents all the immediate assertions which can be tested
    const string lof_all_immediate_assertions[] = {
        "SVAUNIT_FAIL_IF_SVA_DOES_NOT_EXISTS_ERR",
        "SVAUNIT_FAIL_IF_SVA_IS_ENABLE_ERR",
        "SVAUNIT_FAIL_IF_SVA_SUCCEEDED_ERR",
        "SVAUNIT_FAIL_IF_SVA_NOT_SUCCEEDED_ERR",
        "SVAUNIT_FAIL_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR",
        "SVAUNIT_FAIL_IF_SVA_NOT_STARTED_ERR",
        "SVAUNIT_FAIL_IF_SVA_FINISHED_ERR",
        "SVAUNIT_FAIL_IF_SVA_NOT_FINISHED_ERR",
        "SVAUNIT_FAIL_IF_ERR",
        "SVAUNIT_FAIL_IF_ALL_SUCCEEDED_ERR",
        "SVAUNIT_PASS_IF_SVA_DOES_NOT_EXISTS_ERR",
        "SVAUNIT_PASS_IF_SVA_IS_ENABLE_ERR",
        "SVAUNIT_PASS_IF_SVA_SUCCEEDED_ERR",
        "SVAUNIT_PASS_IF_SVA_NOT_SUCCEEDED_ERR",
        "SVAUNIT_PASS_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR",
        "SVAUNIT_PASS_IF_SVA_NOT_STARTED_ERR",
        "SVAUNIT_PASS_IF_SVA_FINISHED_ERR",
        "SVAUNIT_PASS_IF_SVA_NOT_FINISHED_ERR",
        "SVAUNIT_PASS_IF_ERR",
        "SVAUNIT_PASS_IF_ALL_SUCCEEDED_ERR"
    };

    /* Constructor for svaunit_test
     * @param name   : instance name for svaunit_test object
     * @param parent : hierarchical parent for svaunit_test
     */
    function new(string name = "svaunit_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get the VPI interface from UVM config db
        if (!uvm_config_db#(virtual svaunit_vpi_interface)::get(uvm_root::get(), "*", "VPI_VIF", vpi_vif)) begin
            `uvm_fatal(get_test_name(), $sformatf("SVAUnit VPI interface for the %s unit test is not set! Please enable SVAUnit package!", get_test_name()));
        end
    endfunction

    // Update the test's status according to the number of failed assertions
    function void update_status();
        // Update status for SVA coverage
        vpi_vif.update_coverage(get_test_name());

        super.update_status();
    endfunction

    // Enable test to be tested
    virtual function void enable_test();
        enable = 1;
    endfunction

    // Disable test to be tested
    virtual function void disable_test();
        enable = 0;
    endfunction

    // {{{ Functions used for immediate assertions

    /* Create the list of immediate assertion if it doesn't exist any with the given name
     * @param sva_name : SVA tested with immediate assertion
     * @param immediate_assertion_name : immediate assertion to be added
     * @param crt_time : current time at which the immediate assertion has been tested
     * @param crt_status : current status of the immediate assertion tested
     */
    local function void add_lof_immediate_assertions(string sva_name, string immediate_assertion_name, time crt_time, svaunit_status_type crt_status);
        // Stores the fact that the SVA was tested before or not
        bit sva_exist = 0;

        // Verify if SVA was tested before or not - in this case add new detail to immediate assertion list
        if(immediate_assertions.size() > 0) begin
            foreach(immediate_assertions[index]) begin
                if(sva_exist == 0) begin
                    if(immediate_assertions[index].get_sva_tested_name() == sva_name) begin
                        immediate_assertions[index].add_new_detail_immediate_assertion(immediate_assertion_name, crt_time, crt_status);
                        sva_exist = 1;
                    end
                end
            end
        end

        // If the assertion wasn't tested before add new item into immediate_assertions list
        if(sva_exist == 0) begin
            // Increase the immediate assertion size and add new immediate assertion
            svaunit_immediate_assertion_info check = svaunit_immediate_assertion_info::type_id::create($sformatf("%s_immediate_assertions_%0d", get_name(), immediate_assertions.size() - 1), this);
            check.set_sva_name(sva_name);
            check.add_new_detail_immediate_assertion(immediate_assertion_name, crt_time, crt_status);

            immediate_assertions.push_back(check);
        end
    endfunction

    /* Get the immediate assertion info which corresponds to a given SVA
     * @param sva_name : a string represents the SVA name used to select the immediate assertion
     * @return the immediate assertion info which corresponds to a given SVA
     */
    function svaunit_immediate_assertion_info get_immediate_assertion(string sva_name);
        foreach(immediate_assertions[check_index]) begin
            if(immediate_assertions[check_index].get_sva_tested_name() == sva_name) begin
                return immediate_assertions[check_index];
            end
        end

        return null;
    endfunction

    /* Get a list with names for all immediate assertion used
     * @param the string list which contains the name of the checks used in this unit test
     */
    function void get_immediate_assertion_names(ref string immediate_assertions_names[$]);
        // Iterate all over the immediate assertions to get the checks name
        foreach(immediate_assertions[check_index]) begin
            immediate_assertions[check_index].get_immediate_assertion_names(immediate_assertions_names);
        end
    endfunction

    /* Get a list with names for all immediate assertion used which were not used
     * @param the string list which contains the name of the checks not used in this unit test
     */
    function void get_immediate_assertion_not_used_names(ref string immediate_assertions_names[$]);
        // Variable used to store that the immediate assertion exists already or not
        bit exists = 0;

        // Iterate all over the lof_all_immediate_assertions to see if the check was used or not
        foreach(lof_all_immediate_assertions[index]) begin
            // Initialize with 0
            exists = 0;

            // Iterate all over the immediate assertions used and all over the details to see if exits or not
            foreach(immediate_assertions[check_index]) begin
                foreach(immediate_assertions[check_index].immediate_assertion_details[details_index])begin
                    if(lof_all_immediate_assertions[index] == immediate_assertions[check_index].immediate_assertion_details[details_index].get_immediate_assertion_name()) begin
                        exists = 1;
                    end
                end
            end

            // If it was not found the check iterate all over the string queue to see if already exists in that list
            if(exists == 0) begin
                // Variable used to store that the immediate assertion name exists already or not
                bit string_exists = 0;

                // Verify if the string exists or not
                foreach(immediate_assertions_names[not_used_index]) begin
                    if(lof_all_immediate_assertions[index] == immediate_assertions_names[not_used_index]) begin
                        string_exists = 1;
                    end
                end

                // If the string does not exists add to the string queue it's name
                if(string_exists == 0) begin
                    immediate_assertions_names.push_back(lof_all_immediate_assertions[index]);
                end
            end
        end
    endfunction

    /* Get immediate assertions from all tests
     * @return the total number of immediate assertions
     */
    function int unsigned get_total_nof_immediate_assertions();
        return immediate_assertions.size();
    endfunction

    /* Get the number of times an immediate assertion was tested during simulation
     * @return the number of times an immediate assertion was tested during simulation
     */
    function int unsigned get_nof_times_immediate_assertions_tested(string immediate_assertion_name);
        // Variable used to store the number of times a check was tested
        int unsigned nof_times_immediate_assertions_tested = 0;

        // Iterate over the check list and it's detail to see if the given check name was tested and
        // increase the number with the proper number of times the check was tested
        foreach(immediate_assertions[immediate_assertions_index]) begin
            foreach(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index])begin
                if(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index].get_immediate_assertion_name() == immediate_assertion_name) begin
                    nof_times_immediate_assertions_tested = nof_times_immediate_assertions_tested + immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index].get_nof_times_immediate_assertion_tested();
                end
            end
        end

        return nof_times_immediate_assertions_tested;
    endfunction

    /* Get the number of times an immediate assertion passed during simulation
     * @return the number of times an immediate assertion passed during simulation
     */
    function int unsigned get_nof_times_immediate_assertions_passed(string immediate_assertion_name);
        // Variable used to store the number of times a check has passed
        int unsigned nof_times_immediate_assertions_passed = 0;

        // Iterate over the check list and it's detail to see if the given check name was tested and
        // increase the number with the proper number of times the check has tested
        foreach(immediate_assertions[immediate_assertions_index]) begin
            foreach(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index])begin
                if(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index].get_immediate_assertion_name() == immediate_assertion_name) begin
                    nof_times_immediate_assertions_passed = nof_times_immediate_assertions_passed + immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index].get_nof_times_immediate_assertion_pass();
                end
            end
        end

        return nof_times_immediate_assertions_passed;
    endfunction
    // }}}

    // {{{ Functions used to find out SVA properties
    int index = 0;

    /* Get an assertion with a name from list
     * @param assertion_name : assertion name to be found in SVA list
     * @return the assertion from SVA list
     */
    local function svaunit_concurrent_assertion_info get_assertion_from_name(string assertion_name);
        svaunit_status_type a_status;

        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = vpi_vif.get_assertion_from_name(assertion_name);

        index = index + 1;

        // Verify that the SVA exists or not
        fail_if_sva_does_not_exists(assertion_name, $sformatf("Assertion %s doesn't exists.", assertion_name));

        return assertion;
    endfunction

    /* Verify that the SVA with a given name succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion succeeded and 0 otherwise
     */
    local function bit assertion_succeeded(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_succeeded();
        end else begin
            return 0;
        end
    endfunction

    /* Verify that the SVA with a given name failed
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion failed and 0 otherwise
     */
    local function bit assertion_failed(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_failed();
        end else begin
            return 0;
        end
    endfunction

    /* Verify that the SVA with a given name started but has not finished
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion started but has not finished and 0 otherwise
     */
    local function bit assertion_started_but_not_finished(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_has_started_but_has_not_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify that the first state of an SVA with a given name is not start
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the first state of assertion is not start and 0 otherwise
     */
    local function bit first_state_not_start(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_first_state_not_start();
        end else begin
            return 0;
        end
    endfunction

    /* Get the first state of an SVA with a given name
     * @param assertion_name : assertion name to be found in SVA list
     * @return the first state of assertion
     */
    local function svaunit_concurrent_assertion_state_type get_first_state(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.get_sva_first_state();
        end else begin
            return svaunit_concurrent_assertion_state_type'(0);
        end
    endfunction

    /* Get the last state of an SVA with a given name
     * @param assertion_name : assertion name to be found in SVA list
     * @return the last state of assertion
     */
    local function svaunit_concurrent_assertion_state_type get_last_state(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.get_sva_last_state();
        end else begin
            return svaunit_concurrent_assertion_state_type'(0);
        end
    endfunction

    /* Verify that an SVA with a given name has finished
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion has finished and 0 otherwise
     */
    local function bit is_finished(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_is_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify that an SVA with a given name has not finished
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion has not finished and 0 otherwise
     */
    local function bit is_not_finished(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.sva_is_not_finished();
        end else begin
            return 0;
        end
    endfunction

    /* Verify that an SVA with a given name is enable
     * @param assertion_name : assertion name to be found in SVA list
     * @return 1 if the assertion is enable and 0 otherwise
     */
    local function bit is_enable(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.is_enable(get_test_name());
        end else begin
            return 0;
        end
    endfunction

    /* Compute the number of times an SVA with a given name failed
     * @param assertion_name : assertion name to be found in SVA list
     * @return the number of times an assertion failed
     */
    function int get_nof_times_assertion_failed(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.get_nof_times_sva_fails();
        end else begin
            return -1;
        end
    endfunction

    /* Compute the number of times an SVA with a given name succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @return the number of times an assertion succeeded
     */
    function int get_nof_times_assertion_succeeded(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.get_nof_times_sva_succeeded();
        end else begin
            return -1;
        end
    endfunction

    /* Compute the number of times an SVA with a given name started
     * @param assertion_name : assertion name to be found in SVA list
     * @return the number of times an assertion started
     */
    function int get_nof_times_assertion_started(string assertion_name);
        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            return assertion.get_nof_times_sva_started();
        end else begin
            return -1;
        end
    endfunction

    /* Get a list of all SVAs which have the same tested status
     * @param tested_status : tested status used to collect SVA
     * @param sva_tested : a list of all SVAs which have the same tested status
     */
    virtual function void get_sva_tested(ref svaunit_concurrent_assertion_info sva_tested[$]);
        foreach(vpi_vif.sva_info[index]) begin
            if(vpi_vif.sva_info[index].was_tested(get_test_name()) == SVAUNIT_WAS_TESTED) begin
                if(!vpi_vif.sva_exists(vpi_vif.sva_info[index].get_sva_name(), sva_tested)) begin
                    sva_tested.push_back(vpi_vif.sva_info[index]);
                end
            end
        end
    endfunction

    // Get the total number of SVAs
    function int unsigned get_nof_sva();
        return vpi_vif.get_nof_sva();
    endfunction

    /* Get the total number of SVAs tested from all tests
     * @return the total number of SVAs tested from all tests
     */
    virtual function int unsigned get_nof_tested_sva();
        // Variable used to store the tested SVAs
        svaunit_concurrent_assertion_info tested_sva[$];

        // Get all SVA tested
        get_sva_tested(tested_sva);

        return tested_sva.size();
    endfunction

    /* Get the names of the SVAs which were tested during test
     * @return the names of the SVAs which were tested during test
     */
    virtual function void get_sva_tested_names(ref string tested_sva_names[$]);
        // Variable used to store the tested SVAs
        svaunit_concurrent_assertion_info tested_sva[$];

        // Get all SVA tested
        get_sva_tested(tested_sva);

        // Verify if the tested SVA name exists into out list
        foreach(tested_sva[index]) begin
            // Variable used to store that SVA name exists into out list
            bit exists = 0;

            // Iterate all over the SVA names to see if the SVA name exists or not
            foreach(tested_sva_names[sva_index]) begin
                if(tested_sva_names[sva_index] == tested_sva[index].get_sva_name()) begin
                    exists = 1;
                end
            end

            // If it does not exists add into out list
            if(exists == 0) begin
                tested_sva_names.push_back(tested_sva[index].get_sva_name());
            end
        end
    endfunction

    /* Get the names of the SVAs which were not tested during test
     * @return the names of the SVAs which were not tested during test
     */
    virtual function void get_sva_not_tested_names(ref string not_tested_sva_names[$]);
        // Variable used to store the tested SVAs
        svaunit_concurrent_assertion_info sva_not_tested[$];

        // Get all SVA not tested
        get_sva_not_tested(sva_not_tested);

        // Verify if the not tested SVA name exists into out list
        foreach(sva_not_tested[index]) begin
            // Variable used to store that SVA name exists into out list
            bit exists = 0;

            // Iterate all over the SVA names to see if the SVA name exists or not
            foreach(not_tested_sva_names[sva_index]) begin
                if(not_tested_sva_names[sva_index] == sva_not_tested[index].get_sva_name()) begin
                    exists = 1;
                end
            end

            // If it does not exists add into out list
            if(exists == 0) begin
                not_tested_sva_names.push_back(sva_not_tested[index].get_sva_name());
            end
        end
    endfunction

    /* Get all SVA from all tests which have not been tested
     * @param tested_sva : list of all SVAs which have not been tested
     */
    function void get_sva_not_tested(ref svaunit_concurrent_assertion_info sva_not_tested[$]);
        // Variable used to store the tested SVAs
        svaunit_concurrent_assertion_info tested[$];

        // Get all SVA tested
        get_sva_tested(tested);

        // Verify if the not tested SVA name exists into out list
        foreach(vpi_vif.sva_info[index]) begin
            // Variable used to store that SVA exists into out list
            bit exists = 0;

            // Iterate all over the SVAs to see if the SVA exists or not
            foreach(tested[sva_index]) begin
                if(tested[sva_index] == vpi_vif.sva_info[index]) begin
                    exists = 1;
                end
            end

            // If it does not exists add into out list
            if(exists == 0) begin
                sva_not_tested.push_back(vpi_vif.sva_info[index]);
            end
        end
    endfunction
    // }}}


    // {{{ Functions used to control SVA
    //------------------------------- RESET --------------------------------
    /* Will discard all current attempts in progress for an SVA with a given name and resets the SVA to its initial state
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void reset_assertion(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.reset_assertion(get_test_name(), assertion, assertion_name);
        end
    endfunction

    // Will discard all current attempts in progress for all SVAs and resets the SVAs to initial state
    function void reset_all_assertions();
        vpi_vif.reset_all_assertions(get_test_name());
    endfunction

    //------------------------------- DISABLE --------------------------------
    /* Will disable the starting of any new attempt for a given SVA
     * (this will have no effect on any existing attempts or if SVA was already disable; on default all SVAs are enable)
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void disable_assertion(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.disable_assertion(get_test_name(), assertion, assertion_name);
        end
    endfunction

    /* Will disable the starting of any new attempt for all SVAs
     * (this will have no effect on any existing attempts or if SVA was already disable; on default all SVAs are enable)
     */
    function void disable_all_assertions();
        vpi_vif.disable_all_assertions(get_test_name());
    endfunction

    //------------------------------- ENABLE --------------------------------
    /* Will enable starting any new attempts for a given SVA
     * (this will have no effect if SVA was already enable or on any current attempt)
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void enable_assertion(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.enable_assertion(get_test_name(), assertion, assertion_name);
        end
    endfunction

    /* Will enable starting any new attempts for all SVAs
     * (this will have no effect if SVA was already enable or on any current attempt)
     */
    function void enable_all_assertions();
        vpi_vif.enable_all_assertions(get_test_name());
    endfunction

    //------------------------------- KILL --------------------------------
    /* Will discard any attempts of a given SVA
     * (the SVA will remain enabled and does not reset any state used by this SVA)
     * @param assertion_name : assertion name to be found in SVA list
     * @param sim_time : the simulation time from which the SVA attempts will be killed
     */
    function void kill_assertion(string assertion_name, time sim_time);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.kill_assertion(get_test_name(), assertion, assertion_name, sim_time);
        end
    endfunction

    /* Will discard any attempts of all SVAs
     * (the SVA will remain enabled and does not reset any state used by any SVA)
     * @param sim_time : the simulation time from which the SVA attempts will be killed
     */
    function void kill_all_assertions(time sim_time);
        vpi_vif.kill_all_assertions(get_test_name(), sim_time);
    endfunction

    //------------------------------- DISABLE STEP --------------------------------
    /* Will disable step callback for a given SVA
     * (this will have no effect if step callback is not enabled or it was already disabled)
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void disable_step_assertion(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.disable_step_assertion(get_test_name(), assertion, assertion_name);
        end
    endfunction

    /* Will disable step callback for all SVAs
     * (this will have no effect if step callback is not enabled or it was already disabled)
     */
    function void disable_step_all_assertions();
        vpi_vif.disable_step_all_assertions(get_test_name());
    endfunction

    //------------------------------- ENABLE STEP --------------------------------

    /* Will enable step callback for a given SVA
     * (by default, stepping is disabled; this will have no effect if stepping was already enabled; the stepping mode cannot be modified after the assertion attempt has started)
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void enable_step_assertion(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        if(assertion != null) begin
            vpi_vif.enable_step_assertion(get_test_name(), assertion, assertion_name);
        end
    endfunction

    /* Will enable step callback for all SVAs
     * (by default, stepping is disabled; this will have no effect if stepping was already enabled; the stepping mode cannot be modified after the assertion attempt has started)
     */
    function void enable_step_all_assertions();
        vpi_vif.enable_step_all_assertions(get_test_name());
    endfunction

    //------------------------------- SYSTEM RESET --------------------------------
    /* Will discard all attempts in progress for all SVAs and restore the entire assertion system to its initial state.
     * (The vpiAssertionStepSuccess and vpiAssertionStepFailure callbacks will be removed)
     */
    function void system_reset_all_assertions();
        vpi_vif.system_reset_all_assertions();
    endfunction


    //------------------------------- SYSTEM ON --------------------------------
    // Will restart the SVAs after it was stopped
    function void system_on_all_assertions();
        vpi_vif.system_on_all_assertions(get_test_name());
    endfunction


    //------------------------------- SYSTEM OFF --------------------------------
    // Will disable any SVA to being started and all current attempts will be considered as unterminated
    function void system_off_all_assertions();
        vpi_vif.system_off_all_assertions(get_test_name());
    endfunction


    //------------------------------- SYSTEM END --------------------------------
    /* Will discard any attempt in progress and disable any SVA to be started
     * (all callbacks will be removed)
     */
    function void system_end_all_assertions();
        vpi_vif.system_end_all_assertions(get_test_name());
    endfunction
    // }}}

    // {{{ Functions used to check
    /* Verify if the test should fail according to expression and increase the test statistics
     * The test will fail if the expression is false
     * @param expression : the expression bit
     * @return 1 if the expression is TRUE and 0 otherwise
     */
    local function bit check_expression(bit expression);
        // Increase the tests number
        nof_tests = nof_tests + 1;

        // Verify if the expression is FALSE or TRUE. If it is FALSE return 0 and increase the failures number else return 1
        if (expression) begin
            return 1;
        end else begin
            stop = 1;
            nof_failures = nof_failures + 1;
            return 0;
        end
    endfunction

    // ------------------ CHECK THAT ASSERTION IS ENABLE ------------------
    /* Verify automatically that a given SVA is enabled - the test will fail if the SVA is not enabled
     * @param assertion_name : assertion name to be found in SVA list
     */
    local function void check_assertion_is_enable(string assertion_name);
        vpi_vif.get_info_from_c(get_test_name());

        pass_if_sva_enabled(assertion_name, $sformatf("Assertion %s is not enable.", assertion_name));
    endfunction

    // ------------------ CHECK FAIL IF ENABLE -------------------------
    /* Verify if a given SVA is enabled - the test will fail if SVA is enable
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_enabled(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        SVAUNIT_FAIL_IF_SVA_IS_ENABLE_ERR : assert(check_expression(!is_enable(assertion_name)) == 1)  begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_IS_ENABLE_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end
        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_IS_ENABLE_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA is enabled - the test will pass if SVA is enable
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_enabled(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        SVAUNIT_PASS_IF_SVA_IS_ENABLE_ERR : assert(check_expression(is_enable(assertion_name)) == 1)  begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_IS_ENABLE_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end
        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_IS_ENABLE_ERR", $time(), a_status);
    endfunction

    // ------------------ CHECK FAIL IF SVA DOES NOT EXISTS-------------------------
    /* Verify if a given SVA is exists - the test will fail if SVA is does not exists
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_does_not_exists(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = vpi_vif.get_assertion_from_name(assertion_name);

        SVAUNIT_FAIL_IF_SVA_DOES_NOT_EXISTS_ERR : assert((check_expression(assertion != null)) == 1)  begin
            a_status = SVAUNIT_PASS;
            assertion.set_tested(get_test_name());
            add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_DOES_NOT_EXISTS_ERR", $time(), a_status);
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_DOES_NOT_EXISTS_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, "Assertion doesn't exists."))
            a_status = SVAUNIT_FAIL;
            add_lof_immediate_assertions("", "SVAUNIT_FAIL_IF_SVA_DOES_NOT_EXISTS_ERR", $time(), a_status);
        end
    endfunction

    /* Verify if a given SVA is exists - the test will pass if SVA is does not exists
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_does_not_exists(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        // Get the SVA from the SVA list
        svaunit_concurrent_assertion_info assertion = vpi_vif.get_assertion_from_name(assertion_name);

        SVAUNIT_PASS_IF_SVA_DOES_NOT_EXISTS_ERR : assert(check_expression(assertion == null) == 1)  begin
            a_status = SVAUNIT_PASS;
            add_lof_immediate_assertions("", "SVAUNIT_PASS_IF_SVA_DOES_NOT_EXISTS_ERR", $time(), a_status);
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_DOES_NOT_EXISTS_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, "Assertion exists."))
            assertion.set_tested(get_test_name());
            a_status = SVAUNIT_FAIL;
            add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_DOES_NOT_EXISTS_ERR", $time(), a_status);
        end
    endfunction


    // ------------------ CHECK FAIL IF SUCCEEDED -------------------------
    /* Verify if a given SVA succeeded - the test will fail if SVA succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_succeeded(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_SUCCEEDED_ERR : assert(check_expression(!(assertion_succeeded(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_SUCCEEDED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))

            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_SUCCEEDED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA succeeded - the test will fail if SVA does not succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_succeeded(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_SUCCEEDED_ERR : assert(check_expression(assertion_succeeded(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_SUCCEEDED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_SUCCEEDED_ERR", $time(), a_status);
    endfunction

    // ------------------ CHECK FAIL IF NOT SUCCEEDED -------------------------
    /* Verify if a given SVA didn't succeeded (the assertion should have failed) - the test will fail if the assertion didn't succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_not_succeeded(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_NOT_SUCCEEDED_ERR : assert(check_expression(assertion_succeeded(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_NOT_SUCCEEDED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_NOT_SUCCEEDED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA didn't succeeded (the assertion should have failed) - the test will pass if the assertion didn't succeeded
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_not_succeeded(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_NOT_SUCCEEDED_ERR : assert(check_expression(!(assertion_succeeded(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_NOT_SUCCEEDED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_NOT_SUCCEEDED_ERR", $time(), a_status);
    endfunction

    // ------------------ CHECK FAIL IF STARTED BUT NOT FINISHED -------------------------
    /* Verify if a given SVA didn't finished  but the first state is START - the test will fail if the assertion didn't finished but the first state is START
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_started_but_not_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR : assert(check_expression(!(assertion_started_but_not_finished(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA didn't finished  but the first state is START - the test will pass if the assertion didn't finished but the first state is START
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_started_but_not_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR : assert(check_expression(assertion_started_but_not_finished(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_STARTED_BUT_NOT_FINISHED_ERR", $time(), a_status);
    endfunction


    // ------------------ CHECK FAIL IF NOT STARTED -------------------------
    /* Verify if a given SVA didn't started - the test will fail if the assertion didn't started
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_not_started(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_NOT_STARTED_ERR : assert(check_expression(!(first_state_not_start(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_NOT_STARTED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_NOT_STARTED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA didn't started - the test will pass if the assertion didn't started
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_not_started(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_NOT_STARTED_ERR : assert(check_expression(first_state_not_start(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_NOT_STARTED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_NOT_STARTED_ERR", $time(), a_status);
    endfunction


    // ------------------ CHECK FAIL IF FINISHED -------------------------
    /* Verify if a given SVA finished - the test will fail if the assertion finished
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_FINISHED_ERR : assert(check_expression(!(is_finished(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_FINISHED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA finished - the test will pass if the assertion finished
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_FINISHED_ERR : assert(check_expression(is_finished(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_FINISHED_ERR", $time(), a_status);
    endfunction

    // ------------------ CHECK FAIL IF NOT FINISHED -------------------------
    /* Verify if a given SVA didn't finished - the test will fail if the assertion didn't finished
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if_sva_not_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_FAIL_IF_SVA_NOT_FINISHED_ERR : assert(check_expression(!(is_not_finished(assertion_name))) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_SVA_NOT_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_FAIL_IF_SVA_NOT_FINISHED_ERR", $time(), a_status);
    endfunction

    /* Verify if a given SVA didn't finished - the test will pass if the assertion didn't finished
     * @param assertion_name : assertion name to be found in SVA list
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if_sva_not_finished(string assertion_name, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        check_assertion_is_enable(assertion_name);

        SVAUNIT_PASS_IF_SVA_NOT_FINISHED_ERR : assert(check_expression(is_not_finished(assertion_name)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_SVA_NOT_FINISHED_ERR", $sformatf("[%s::%s %s] %s", get_test_name(), get_type_name(), assertion_name, error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions(assertion_name, "SVAUNIT_PASS_IF_SVA_NOT_FINISHED_ERR", $time(), a_status);
    endfunction


    // ------------------ CHECK FAIL IF  -------------------------
    /* Verify if the expression is FALSE - the test will fail if the expression is FALSE
     * @param expression : the expression to be checked
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void fail_if(bit expression, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        SVAUNIT_FAIL_IF_ERR : assert(check_expression(!(expression)) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_ERR", $sformatf("[%s::%s] %s", get_test_name(), get_type_name(), error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions("SVAUNIT_PASS_IF_ERR", "SVAUNIT_FAIL_IF_ERR", $time(), a_status);
    endfunction

    /* Verify if the expression is FALSE - the test will pass if the expression is FALSE
     * @param expression : the expression to be checked
     * @param error_msg : user error message to be printed if the check fails
     * @param line : the line number where the check is exercised
     * @param filename : the file name where the check is exercised
     */
    function void pass_if(bit expression, string error_msg = "Default message", int unsigned line = 0, string filename = "");
        svaunit_status_type a_status;

        SVAUNIT_PASS_IF_ERR : assert(check_expression(expression) == 1) begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_ERR", $sformatf("[%s::%s] %s", get_test_name(), get_type_name(), error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions("SVAUNIT_PASS_IF_ERR", "SVAUNIT_PASS_IF_ERR", $time(), a_status);
    endfunction

    // Automatic check verified at the end of test for all enabled SVAs, if there are not any checks in unit test
    function void pass_assertion();
        if(immediate_assertions.size() == 0) begin
            if(vpi_vif.sva_info.size() > 0) begin
                foreach(vpi_vif.sva_info[sva_index]) begin
                    if(is_enable(vpi_vif.sva_info[sva_index].get_sva_name())) begin
                        fail_if_sva_not_succeeded(vpi_vif.sva_info[sva_index].get_sva_name(), $sformatf("Assertion %s should have succeeded, found instead: %s", vpi_vif.sva_info[sva_index].get_sva_name(), vpi_vif.sva_info[sva_index].get_sva_last_state()));
                    end
                end
            end
        end
    endfunction

    // Verify if all SVAs succeeded - the test will pass if all SVA succeeded
    function void pass_if_all_sva_succeeded(string error_msg);
        svaunit_status_type a_status;

        // Shows that all SVAs succeeded in this test
        bit all_succeeded = 1;

        foreach(vpi_vif.sva_info[sva_index]) begin
            if(vpi_vif.sva_info[sva_index].is_enable(get_test_name())) begin
                string sva_name = vpi_vif.sva_info[sva_index].get_sva_name();
                if((get_nof_times_assertion_failed(sva_name) != 0) || (get_nof_times_assertion_succeeded(sva_name) == 0)) begin
                    all_succeeded = 0;
                end
            end
        end

        SVAUNIT_PASS_IF_ALL_SUCCEEDED_ERR : assert(check_expression(all_succeeded == 1) == 1)begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_PASS_IF_ALL_SUCCEEDED_ERR", $sformatf("[%s::%s] %s", get_test_name(), get_type_name(), error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions("", "SVAUNIT_PASS_IF_ALL_SUCCEEDED_ERR", $time(), a_status);
    endfunction

    // Verify if all SVAs succeeded - the test will fail if all SVA succeeded
    function void fail_if_all_sva_succeeded(string error_msg);
        svaunit_status_type a_status;

        // Shows that all SVAs succeeded in this test
        bit all_succeeded = 1;

        foreach(vpi_vif.sva_info[sva_index]) begin
            if(vpi_vif.sva_info[sva_index].is_enable(get_test_name())) begin
                string sva_name = vpi_vif.sva_info[sva_index].get_sva_name();
                if((get_nof_times_assertion_failed(sva_name) != 0) || (get_nof_times_assertion_succeeded(sva_name) == 0)) begin
                    all_succeeded = 0;
                end
            end
        end

        SVAUNIT_FAIL_IF_ALL_SUCCEEDED_ERR : assert(!(check_expression(all_succeeded == 1)) == 1)begin
            a_status = SVAUNIT_PASS;
        end else begin
            `uvm_error("SVAUNIT_FAIL_IF_ALL_SUCCEEDED_ERR", $sformatf("[%s::%s] %s", get_test_name(), get_type_name(), error_msg))
            a_status = SVAUNIT_FAIL;
        end

        add_lof_immediate_assertions("", "SVAUNIT_FAIL_IF_ALL_SUCCEEDED_ERR", $time(), a_status);
    endfunction
    // }}}


    // {{{ Running tasks

    // Task used to start testing - The user should create here scenarios to verify SVAs
    pure virtual task test();

    // Define a behavior that will happens before running the test
    // E.g. initialize signals
    pure virtual task pre_test();

    // Define a behavior that will happens after running the test
    virtual task post_test();
    endtask

    // Will start the unit test and will start the timeout mechanism
    virtual task start_ut();
        if(enable == 1) begin
            fork
                begin
                    // Variable used to store the process id for test task
                    process simulate_test;
                    fork
                        begin
                            simulate_test = process::self();
                            fork
                                begin
                                    set_test_name_vpi(get_test_name());
                                    pre_test();
                                    test();
                                    post_test();
                                    pass_assertion();
                                end
                                begin
                                    #timeout;
                                    `uvm_error("SVAUNIT_TIMEOUT_ERR", "Max simulation timeout reached!")
                                end
                                begin
                                    while(stop == 0) begin
                                        #1;
                                    end
                                end
                            join_any
                        end
                    join
                    disable fork;
                    simulate_test.kill();
                end
            join
        end
    endtask

    /* Set test name in VPI interface
     * @param test_name to be added inside VPI interface
     */
    function void set_test_name_vpi(string test_name);
        vpi_vif.set_test_name(test_name);
    endfunction

    /* Run phase method used to run test - it will be started only in VMANAGER mode
     * @param phase : the phase scheduled for run_phase method
     */
    virtual task run_phase(uvm_phase phase);
        // Get parent of this test
        uvm_component parent = get_parent();

        // If the test haven't started and it's parent is null, it should start from here
        if(!started() && parent.get_name() == "") begin
            // Raise objection mechanism for this test
            uvm_test_done.raise_objection(this, "", 1);

            // Set start test, run test and after that print report
            if(enable == 1) begin
                start_test();
                set_test_name_vpi(get_test_name());
                fork
                    begin
                        // Variable used to store the process id for start_up task
                        process start_ut_p;
                        fork
                            begin
                                start_ut_p = process::self();
                                start_ut();
                                disable fork;
                            end
                        join
                        start_ut_p.kill();
                    end
                join
                update_status();
                print_report();
            end

            // Drop objection mechanism for this test
            uvm_test_done.drop_objection(this, "", 1);
        end
    endtask
    // }}}

    // {{{ Print functions
    /* Form the status to be printed
     * @return a string represents the status to be printed
     */
    function void print_status();
        string report = "";

        report = $sformatf("\n\n-------------------- %s unit test : Status statistics --------------------", get_test_name());
        report = $sformatf("%s\n\t%s\n", report, get_status_as_string());

        `uvm_info(get_test_name(), report, UVM_LOW);
    endfunction

    /* Form the status to be printed as a string
     * @return a string represents the status to be printed
     */
    virtual function string get_status_as_string();
        string star = " ";

        if(get_status() == SVAUNIT_FAIL) begin
            star = "*";
        end

        return $sformatf("\n\t%s   %s %s (%0d/%0d assertions PASSED)", star, get_test_name(), status.name(), nof_tests - nof_failures, nof_tests);
    endfunction

    /* Form the status of the test as a string
     * @return a string which contains the status of test
     */
    virtual function string get_status_tests();
        return get_status_as_string();
    endfunction

    // Print a list with all SVAs and with its status
    function void print_sva();
        `uvm_info(get_test_name(), $sformatf("%s\n", vpi_vif.report_for_sva(get_test_name(), get_type_name())), UVM_LOW);
    endfunction

    // Print a report for all checks tested for the current unit test
    function void print_checks();
        string report = "";
        string star = "";
        string extra = "";
        string immediate_assertions_names[$];
        string immediate_assertions_not_used_names[$];
        int unsigned nof_times_immediate_assertion_tested;
        int unsigned nof_times_immediate_assertion_passed;
        get_immediate_assertion_names(immediate_assertions_names);
        get_immediate_assertion_not_used_names(immediate_assertions_not_used_names);

        report = $sformatf("\n\n-------------------- %s unit test : Checks statistics --------------------\n\n", get_test_name());
        report = $sformatf("%s\t%0d/%0d Checks were exercised\n\n", report,  immediate_assertions_names.size(), immediate_assertions_names.size() + immediate_assertions_not_used_names.size());

        foreach(immediate_assertions_names[index]) begin
            nof_times_immediate_assertion_tested = 0;
            nof_times_immediate_assertion_passed = 0;
            star = " ";
            extra = "";

            foreach(immediate_assertions[immediate_assertions_index]) begin
                foreach(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index])begin
                    if(immediate_assertions[immediate_assertions_index].immediate_assertion_details[details_index].get_immediate_assertion_name() == immediate_assertions_names[index]) begin
                        nof_times_immediate_assertion_tested = get_nof_times_immediate_assertions_tested(immediate_assertions_names[index]);
                        nof_times_immediate_assertion_passed = get_nof_times_immediate_assertions_passed(immediate_assertions_names[index]);

                        if(nof_times_immediate_assertion_passed < nof_times_immediate_assertion_tested) begin
                            star = "*";
                        end

                        extra = $sformatf("%0d/%0d times PASSED", nof_times_immediate_assertion_passed, nof_times_immediate_assertion_tested);
                    end
                end
            end

            report = $sformatf("%s\t   %s   %s %s \n", report, star, immediate_assertions_names[index], extra);
        end

        if(immediate_assertions_not_used_names.size() > 0) begin
            report = $sformatf("%s\n\t%0d/%0d Checks were not exercised\n\n", report, immediate_assertions_not_used_names.size(), immediate_assertions_names.size() + immediate_assertions_not_used_names.size());

            foreach(immediate_assertions_not_used_names[index]) begin
                report = $sformatf("%s\t\t%s\n", report, immediate_assertions_not_used_names[index]);
            end
        end

        report = $sformatf("%s\n\n", report);

        `uvm_info(get_test_name(), $sformatf("%s\n", report), UVM_LOW);
    endfunction

    // Print a report for all checks tested for the SVAs
    function void print_sva_and_checks();
        string report = "";

        report = $sformatf("\n\n-------------------- %s unit test : SVA and checks statistics --------------------\n", get_test_name());

        foreach(immediate_assertions[immediate_assertions_index]) begin
            report = $sformatf("%s\n\t%s", report, immediate_assertions[immediate_assertions_index].get_immediate_assertion_details());
        end

        report = $sformatf("%s", report);

        `uvm_info(get_test_name(), $sformatf("%s\n", report), UVM_LOW);
    endfunction

    // Print a report for all SVA which have failed
    function void print_failed_sva();
        string report = "";
        string details = "";

        report = $sformatf("\n\n-------------------- %s unit test : Failed SVA --------------------\n", get_test_name());

        foreach(immediate_assertions[immediate_assertions_index]) begin
            details = immediate_assertions[immediate_assertions_index].get_sva_failed_details();
            if(details != "") begin
                report = $sformatf("%s\n\t%s", report, immediate_assertions[immediate_assertions_index].get_sva_failed_details());
            end
        end

        report = $sformatf("%s", report);

        `uvm_info(get_test_name(), $sformatf("%s\n", report), UVM_LOW);
    endfunction

    /* Get a string with all checks used to verify SVAs
     * @return a string represents the checks tested for SVAs
     */
    function string get_immediate_assertion_sva();
        string report = "";

        foreach(immediate_assertions[immediate_assertions_index]) begin
            report = $sformatf("%s\n\t%s", report, immediate_assertions[immediate_assertions_index].get_immediate_assertion_details());
        end

        report = $sformatf("%s", report);
        return report;
    endfunction

    /* Form the tree from test-suites names and tests name
     * @return a string representing the tree
     */
    virtual function string form_tree(int num);
        string extra = "";

        for(int i = 0; i < num; i++) begin
            extra = {"\t", extra};
        end

        return $sformatf("%s%s", extra, get_test_name());
    endfunction

    // Print the the SVAUnit topology
    function void print_tree();
        string report = "";

        report = $sformatf("\n%s", form_tree(0));

        `uvm_info(get_test_name(), report, UVM_LOW)
    endfunction

    // Will print the report for the current unit test
    function void print_report();
        update_status();
        print_status();
        print_sva();
        print_checks();
        print_sva_and_checks();
        print_failed_sva();
    endfunction


    /* Will print assertion info for an SVA with a given name
     * @param assertion_name : assertion name to be found in SVA list
     */
    function void print_sva_info(string assertion_name);
        svaunit_concurrent_assertion_info assertion = get_assertion_from_name(assertion_name);

        vpi_vif.get_info_from_c(get_test_name());

        if(assertion != null) begin
            assertion.print_sva_info(get_test_name());
        end
    endfunction
// }}}
endclass

`endif

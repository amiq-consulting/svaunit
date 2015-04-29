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
 * NAME:        svaunit_vpi_interface.sv
 * PROJECT:     svaunit
 * Description: It contains communication API with VPI
 *******************************************************************************/

`ifndef __SVAUNIT_VPI_INTERFACE_SV
//protection against multiple includes
`define __SVAUNIT_VPI_INTERFACE_SV

// It contains communication API with VPI
interface svaunit_vpi_interface();
    import svaunit_pkg::*;
    import uvm_pkg::*;
    `include  "uvm_macros.svh"
    `include  "svaunit_defines.svh"

    // DPI-C API used to find SVAs using VPI API
    import "DPI-C" context function void register_assertions();

    /* Control assertion using vpi_control function
     * @param assertion_name : the assertion used to apply control action on
     * @param control_type : the control action
     * @param sys_time : attempt time
     */
    import "DPI-C" context function void control_assertion(input string assertion_name, input int control_type, input int sys_time);

    /* DPI-C API used to get SVA cover statistics - how many times this cover was triggered and how many times it failed
     * @param cover_name : cover name to retrieve information about
     * @param nof_attempts_failed_covered : number of attempts this cover was triggered and it failed
     * @param nof_attempts_succeeded_covered : number of attempts this cover was triggered and it succeeded
     */
    import "DPI-C" context function void get_cover_statistics(input string cover_name, output int unsigned nof_attempts_covered, output int unsigned nof_attempts_succeeded_covered);

    /* DPI-C API to retrieve information about all callbacks
     * @param crt_test_name : the test name from which this function is called
     */
    import "DPI-C" context function void call_callback(input string crt_test_name);

    /* Set the current test_name
     * @param crt_test_name : current test name to be updated
     */
    import "DPI-C" context function void set_test_name_to_vpi(input string crt_test_name);

    /* VPI API to update a given SVA
     * @param crt_test_name : test name from where this function is called
     * @param assertion_name : SVA name to be updated
     * @param assertion_type : the type of the SVA to be updated
     * @param reason : callback reason
     * @param start_time : the start attempt for this SVA
     * @param callback_time : the callback time for this SVA attempt
     */
    export "DPI-C" function pass_info_to_sv;

    /* Create SVA with a name and a type given
     * @param assertion_name : SVA name to be created
     * @param assertion_type : SVA type to be created
     */
    export "DPI-C" function create_assertion;

    // Stores the test name to be simulated
    string test_name;

    // Will store the info for all assertions from an interface
    svaunit_concurrent_assertion_info sva_info[];

    // Will store the info for all cover assertions from an interface
    svaunit_concurrent_assertion_info cover_assertion_info[];

    // Will store the info for all cover assertions from an interface
    svaunit_concurrent_assertion_info property_assertion_info[];

    initial begin
        register_assertions();
    end

    /* Set test name in VPI interface
     * @param test_name to be added inside VPI interface
     */
    function void set_test_name(string crt_test_name);
        test_name = crt_test_name;

        set_test_name_to_vpi(test_name);
    endfunction

    /* Retrieve info about SVAs
     * @param crt_test_name : test name from where this function is called
     */
    function void get_info_from_c(string crt_test_name);
        call_callback(crt_test_name);
    endfunction

    /* Verify if an SVA assertion exists into SVA list
     * @param assertion_name : the SVA to be found into list
     * @param lof_sva : the list of SVAs
     * @return 1 if given SVA exists into list and 0 otherwise
     */
    function bit sva_exists(string assertion_name, svaunit_concurrent_assertion_info lof_sva[]);
        if(lof_sva.size() > 0) begin
            foreach(lof_sva[sva_index]) begin
                if(lof_sva[sva_index].get_sva_name() == assertion_name) begin
                    return 1;
                end
            end
        end

        return 0;
    endfunction

    /* Get the state for an SVA according to a callback reason
     * @param reason : the integer to be transformed to a callback reason
     * @return a state of an SVA transformed from a callback reason
     */
    function svaunit_concurrent_assertion_state_type get_state_from_reason(int reason);
        if (reason inside {`SVAUNIT_VPI_CB_ASSERTION_START, `SVAUNIT_VPI_CB_ASSERTION_SUCCESS, `SVAUNIT_VPI_CB_ASSERTION_FAILURE, `SVAUNIT_VPI_CB_ASSERTION_STEP_SUCCESS, `SVAUNIT_VPI_CB_ASSERTION_STEP_FAILURE, `SVAUNIT_VPI_CB_ASSERTION_DISABLE, `SVAUNIT_VPI_CB_ASSERTION_ENABLE, `SVAUNIT_VPI_CB_ASSERTION_RESET, `SVAUNIT_VPI_CB_ASSERTION_KILL}) begin
            if(reason == `SVAUNIT_VPI_CB_ASSERTION_START) begin
                return SVAUNIT_START;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_SUCCESS) begin
                return SVAUNIT_SUCCESS;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_FAILURE) begin
                return SVAUNIT_FAILURE;
            end
            if(reason == `SVAUNIT_VPI_CB_ASSERTION_STEP_SUCCESS) begin
                return SVAUNIT_STEP_SUCCESS;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_STEP_FAILURE) begin
                return SVAUNIT_STEP_FAILURE;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_DISABLE) begin
                return SVAUNIT_DISABLE;
            end
            if(reason == `SVAUNIT_VPI_CB_ASSERTION_ENABLE) begin
                return SVAUNIT_ENABLE;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_RESET) begin
                return SVAUNIT_RESET;
            end
            else if(reason == `SVAUNIT_VPI_CB_ASSERTION_KILL) begin
                return SVAUNIT_KILL;
            end
        end else begin
            return SVAUNIT_IDLE;
        end
    endfunction

    /* Update SVA info according to a reason
     * @param crt_test_name : test name from where this function is called
     * @param assertion_name : SVA name to be updated
     * @param assertion_type : the type of the SVA to be updated
     * @param reason : callback reason
     * @param start_time : the start attempt for this SVA
     * @param callback_time : the callback time for this SVA attempt
     * @param lof_sva : the list of SVAs which contains the SVA to be updated
     */
    function void update_sva_from_c(string crt_test_name, string assertion_name, string assertion_type, int reason, int start_time, int callback_time, svaunit_concurrent_assertion_info lof_sva[]);
        foreach(lof_sva[index]) begin
            if((lof_sva[index].get_sva_name() == assertion_name) && (lof_sva[index].get_sva_type() == assertion_type)) begin
                static svaunit_concurrent_assertion_state_type crt_state = get_state_from_reason(reason);

                crt_state = svaunit_concurrent_assertion_state_type'(reason);

                if(crt_state inside {SVAUNIT_START, SVAUNIT_SUCCESS, SVAUNIT_FAILURE, SVAUNIT_STEP_SUCCESS, SVAUNIT_STEP_FAILURE, SVAUNIT_DISABLE, SVAUNIT_ENABLE, SVAUNIT_RESET, SVAUNIT_KILL}) begin
                    lof_sva[index].update_details(crt_test_name, start_time, callback_time, crt_state);
                end
            end
        end
    endfunction

    /* Create SVA with a name and a type given
     * @param assertion_name : SVA name to be created
     * @param assertion_type : SVA type to be created
     */
    function void create_assertion(string assertion_name, string assertion_type);
        if(assertion_type == "vpiCover") begin
            if(!(sva_exists(assertion_name, cover_assertion_info))) begin
                // Create and add an assertion info to assertion_info array
                cover_assertion_info = new[cover_assertion_info.size() + 1] (cover_assertion_info);
                cover_assertion_info[cover_assertion_info.size() - 1] = svaunit_concurrent_assertion_info::type_id::create($sformatf("sva_%s", assertion_name), null);
                cover_assertion_info[cover_assertion_info.size() - 1].create_new_sva(assertion_name, assertion_type);
            end
        end else if(assertion_type == "vpiAssert") begin
            if(!(sva_exists(assertion_name, sva_info))) begin
                // Create and add an assertion info to assertion_info array
                sva_info = new[sva_info.size() + 1] (sva_info);
                sva_info[sva_info.size() - 1] = svaunit_concurrent_assertion_info::type_id::create($sformatf("sva_%s", assertion_name), null);
                sva_info[sva_info.size() - 1].create_new_sva(assertion_name, assertion_type);
            end
        end else if(assertion_type == "vpiPropertyInst" || assertion_type == "vpiPropertyDecl") begin
            if(!(sva_exists(assertion_name, property_assertion_info))) begin
                // Create and add an assertion info to assertion_info array
                property_assertion_info = new[property_assertion_info.size() + 1] (property_assertion_info);
                property_assertion_info[property_assertion_info.size() - 1] = svaunit_concurrent_assertion_info::type_id::create($sformatf("property_%s", assertion_name), null);
                property_assertion_info[property_assertion_info.size() - 1].create_new_sva(assertion_name, assertion_type);
            end
        end
    endfunction

    /* VPI API to update a given SVA
     * @param crt_test_name : test name from where this function is called
     * @param assertion_name : SVA name to be updated
     * @param assertion_type : the type of the SVA to be updated
     * @param reason : callback reason
     * @param start_time : the start attempt for this SVA
     * @param callback_time : the callback time for this SVA attempt
     */
    function void pass_info_to_sv(string crt_test_name, string assertion_name, string assertion_type, int reason, int callback_time, int start_time);
        if(assertion_type == "vpiCover") begin
            update_sva_from_c(crt_test_name, assertion_name, assertion_type, reason, start_time, callback_time, cover_assertion_info);
        end else if(assertion_type == "vpiAssert") begin
            update_sva_from_c(crt_test_name, assertion_name, assertion_type, reason, start_time, callback_time, sva_info);
        end else if(assertion_type == "vpiPropertyInst" || assertion_type == "vpiPropertyDecl") begin
            update_sva_from_c(crt_test_name, assertion_name, assertion_type, reason, start_time, callback_time, property_assertion_info);
        end
    endfunction

    /* Get the SVA with the given name
     * @param assertion_name : SVA name to be found
     * @return the SVA with the given name
     */
    function svaunit_concurrent_assertion_info get_assertion_from_name(string assertion_name);
        foreach(sva_info[index]) begin
            if(sva_info[index].get_sva_name() == assertion_name) begin
                return sva_info[index];
            end
        end

        return null;
    endfunction

    // {{{ Functions used to control SVA
    //------------------------------- RESET --------------------------------
    /* Will discard all current attempts in progress for an SVA with a given name and resets the SVA to its initial state
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to be reseted
     * @param assertion_name : assertion name to be reseted
     */
    function void reset_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name);
        assertion.set_enable(test_name, 1);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_RESET_ASSERTION, $time());
    endfunction

    /* Will discard all current attempts in progress for all SVAs and resets the SVAs to initial state
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void reset_all_assertions(string test_name);
        foreach(sva_info[index]) begin
            reset_assertion(test_name, sva_info[index], sva_info[index].get_sva_name());
        end
    endfunction

    //------------------------------- DISABLE --------------------------------
    /* Will disable the starting of any new attempt for a given SVA
     * (this will have no effect on any existing attempts or if SVA was already disable; on default all SVAs are enable)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to be disabled
     * @param assertion_name : assertion name to be disabled
     */
    function void disable_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name);
        assertion.set_enable(test_name, 0);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_DISABLE_ASSERTION, $time());
    endfunction

    /* Will disable the starting of any new attempt for all SVAs
     * (this will have no effect on any existing attempts or if SVA was already disable; on default all SVAs are enable)
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void disable_all_assertions(string test_name);
        foreach(sva_info[index]) begin
            disable_assertion(test_name, sva_info[index], sva_info[index].get_sva_name());
        end
    endfunction

    //------------------------------- ENABLE --------------------------------
    /* Will enable starting any new attempts for a given SVA
     * (this will have no effect id SVA was already enable or on any current attempt)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to be enabled
     * @param assertion_name : assertion name to be enabled
     */
    function void enable_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name);
        assertion.set_enable(test_name, 1);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_ENABLE_ASSERTION, $time());
    endfunction

    /* Will enable starting any new attempts for all SVAs
     * (this will have no effect id SVA was already enable or on any current attempt)
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void enable_all_assertions(string test_name);
        foreach(sva_info[index]) begin
            enable_assertion(test_name, sva_info[index], sva_info[index].get_sva_name());
        end
    endfunction

    //------------------------------- KILL --------------------------------
    /* Will discard any attempts of a given SVA
     * (the SVA will remain enabled and does not reset any state used by this SVA)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to be killed
     * @param assertion_name : assertion name to be killed
     * @param sim_time : the time from which any attempt of a given SVA will be discarded
     */
    function void kill_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name, time sim_time);
        assertion.set_enable(test_name, 1);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_KILL_ASSERTION, sim_time);
    endfunction

    /* Will discard any attempts of all SVAs
     * (the SVA will remain enabled and does not reset any state used by any SVA)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param sim_time : the time from which any attempt of a given SVA will be discarded
     */
    function void kill_all_assertions(string test_name, time sim_time);
        foreach(sva_info[index]) begin
            kill_assertion(test_name, sva_info[index], sva_info[index].get_sva_name(), sim_time);
        end
    endfunction

    //------------------------------- DISABLE STEP --------------------------------
    /* Will disable step callback for a given SVA
     * (this will have no effect if step callback is not enabled or it was already disabled)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to disable stepping for
     * @param assertion_name : assertion name to disable stepping for
     */
    function void disable_step_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name);
        assertion.set_enable(test_name, 1);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_DISABLE_STEP_ASSERTION, $time());
    endfunction

    /* Will disable step callback for all SVAs
     * (this will have no effect if step callback is not enabled or it was already disabled)
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void disable_step_all_assertions(string test_name);
        foreach(sva_info[index]) begin
            disable_step_assertion(test_name, sva_info[index], sva_info[index].get_sva_name());
        end
    endfunction

    //------------------------------- ENABLE STEP --------------------------------

    /* Will enable step callback for a given SVA
     * (by default, stepping is disabled; this will have no effect if stepping was already enabled; the stepping mode cannot be modified after the assertion attempt has started)
     * @param test_name : the test name from which SVA were enabled and tested
     * @param assertion : assertion which needs to enable stepping for
     * @param assertion_name : assertion name to enable stepping for
     */
    function void enable_step_assertion(string test_name, svaunit_concurrent_assertion_info assertion, string assertion_name);
        assertion.set_enable(test_name, 1);
        control_assertion(assertion_name, `SVAUNIT_VPI_CONTROL_ENABLE_STEP_ASSERTION, $time());
    endfunction

    /* Will enable step callback for all SVAs
     * (by default, stepping is disabled; this will have no effect if stepping was already enabled; the stepping mode cannot be modified after the assertion attempt has started)
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void enable_step_all_assertions(string test_name);
        foreach(sva_info[index]) begin
            enable_step_assertion(test_name, sva_info[index], sva_info[index].get_sva_name());
        end
    endfunction

    //------------------------------- SYSTEM RESET --------------------------------
    /* Will discard all attempts in progress for all SVAs and restore the entire assertion system to its initial state.
     * (The vpiAssertionStepSuccess and vpiAssertionStepFailure callbacks will be removed)
     */
    function void system_reset_all_assertions();
        control_assertion("", `SVAUNIT_VPI_CONTROL_SYSTEM_RESET_ASSERTION, $time());
    endfunction


    //------------------------------- SYSTEM ON --------------------------------
    /* Will restart the SVAs after it was stopped
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void system_on_all_assertions(string test_name);
        control_assertion("", `SVAUNIT_VPI_CONTROL_SYSTEM_ON_ASSERTION, $time());

        foreach(sva_info[index]) begin
            sva_info[index].set_enable(test_name, 1);
        end
    endfunction


    //------------------------------- SYSTEM OFF --------------------------------
    /* Will disable any SVA to being started and all current attempts will be considered as unterminated
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void system_off_all_assertions(string test_name);
        control_assertion("", `SVAUNIT_VPI_CONTROL_SYSTEM_OFF_ASSERTION, $time());

        foreach(sva_info[index]) begin
            sva_info[index].set_enable(test_name, 0);
        end
    endfunction


    //------------------------------- SYSTEM END --------------------------------
    /* Will discard any attempt in progress and disable any SVA to be started
     * (all callbacks will be removed)
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void system_end_all_assertions(string test_name);
        control_assertion("", `SVAUNIT_VPI_CONTROL_SYSTEM_END_ASSERTION, $time());

        foreach(sva_info[index]) begin
            sva_info[index].set_enable(test_name, 0);
        end
    endfunction
    // }}}

    /* Update SVA cover
     * @param test_name : the test name from which SVA were enabled and tested
     */
    function void update_coverage(string test_name);
        automatic int nof_attempts_failed_covered;
        automatic int nof_attempts_successful_covered;

        foreach(cover_assertion_info[index]) begin
            if(cover_assertion_info[index].is_enable(test_name)) begin
                get_cover_statistics(cover_assertion_info[index].get_sva_name(), nof_attempts_failed_covered, nof_attempts_successful_covered);
                cover_assertion_info[index].set_nof_attempts_failed_covered(nof_attempts_failed_covered);
                cover_assertion_info[index].set_nof_attempts_successfull_covered(nof_attempts_successful_covered);
            end
        end
    endfunction

    /* Computes how many SVAs are enabled during simulation
     * @param test_name : the test name from which SVA were enabled and tested
     * @return number of SVA which are enabled during simulation
     */
    function int unsigned get_nof_enabled_sva(string test_name);
        // It stores the number of SVA enabled during simulation
        automatic int unsigned nof_sva_enabled = 0;

        //For each SVA verify if it is enabled and increase the counter
        foreach(sva_info[index]) begin
            if(sva_info[index].was_enable(test_name)) begin
                nof_sva_enabled = nof_sva_enabled + 1;
            end
        end

        return nof_sva_enabled;
    endfunction

    /* Computes how many SVAs were tested during simulation
     * @param test_name : the test name from which SVA were enabled and tested
     * @return number of SVA which were tested during simulation
     */
    function int unsigned get_nof_tested_sva(string test_name);
        // It stores the number of SVA tested during simulation
        automatic int unsigned nof_sva_tested = 0;

        //For each SVA verify if it was tested and increase the counter
        foreach(sva_info[index]) begin
            if(sva_info[index].was_tested(test_name)) begin
                nof_sva_tested = nof_sva_tested + 1;
            end
        end

        return nof_sva_tested;
    endfunction

    // Get the total number of SVAs
    function int unsigned get_nof_sva();
        return sva_info.size();
    endfunction

    /* Form the report status of SVA
     * @param test_name : the test name from which SVA were enabled and tested
     * @return the report status for all SVAs
     */
    function string report_for_sva(string test_name, string test_type);
        // Stores the report
        static string report = "";

        // Stores extra report
        static string extra = "";

        // Stores how many SVAs were enabled during simulation
        int unsigned nof_enabled_sva;

        // Stores how many SVAs were tested during simulation
        int unsigned nof_tested_sva;

        // Initialize counters
        nof_enabled_sva = get_nof_enabled_sva(test_name);
        nof_tested_sva = get_nof_tested_sva(test_name);

        // Header for SVAs
        report = $sformatf("\n\n-------------------- %s::%s unit test: SVAs statistics --------------------\n\n", test_name, test_type);

        // Print how many enabled SVA are from a total number of SVA
        report = $sformatf("%s\t%0d/%0d SVA were enabled: \n", report, nof_enabled_sva, get_nof_sva());

        // Form the SVAs enabled
        foreach(sva_info[index]) begin
            if(sva_info[index].was_enable(test_name)) begin
                report = $sformatf("%s\t\t%s\n", report, sva_info[index].get_sva_name());
            end
        end

        // Print how many tested SVA are from a total number of enabled SVA
        report = $sformatf("%s\n\n\t%0d/%0d SVA were exercised : \n", report, nof_tested_sva, sva_info.size());

        // Form the SVAs tested
        foreach(sva_info[index]) begin
            if(sva_info[index].was_tested(test_name)) begin
                report = $sformatf("%s\t\t%s\n", report, sva_info[index].get_sva_name());
            end
        end

        // Print how many not tested SVA are from a total number of enabled SVA
        report = $sformatf("%s\n\n\t%0d/%0d SVA were not exercised : \n", report, sva_info.size() - nof_tested_sva, sva_info.size());

        // Form the SVAs not tested
        foreach(sva_info[index]) begin
            if(!sva_info[index].was_tested(test_name)) begin
                report = $sformatf("%s\t\t%s\n", report, sva_info[index].get_sva_name());
            end
        end

        // Header for cover SVAs
        report = $sformatf("%s\n\n-------------------- %s::%s unit test: Cover statistics --------------------\n\n", report, test_name, test_type);

        // Form the cover SVA
        foreach(cover_assertion_info[index]) begin
            if(cover_assertion_info[index].is_enable(test_name)) begin
                extra = $sformatf("%0d SUCCEEDED, %0d FAILED", cover_assertion_info[index].get_nof_attempts_successful_covered(), cover_assertion_info[index].get_nof_attempts_failed_covered());

                report = $sformatf("%s\t%s %s\n", report, cover_assertion_info[index].get_sva_name(), extra);
            end
        end

        return report;
    endfunction
endinterface

`endif

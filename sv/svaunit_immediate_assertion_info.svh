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
 * MODULE:       svaunit_immediate_assertion_info.svh
 * PROJECT:      svaunit
 * Description:  Immediate assertion class - it contains SVA tested name and a list of details
 *******************************************************************************/

`ifndef __SVAUNIT_IMMEDIATE_ASSERTION_INFO_SVH
//protection against multiple includes
`define __SVAUNIT_IMMEDIATE_ASSERTION_INFO_SVH

// Immediate assertion class - it contains SVA tested name and a list of details
class svaunit_immediate_assertion_info extends uvm_object;
    `uvm_object_utils(svaunit_immediate_assertion_info)

    // Will store the name of tested SVA
    local string sva_tested_name;

    // Will store a list of details for immediate assertion
    svaunit_immediate_assertion_details immediate_assertion_details[];

    /* Constructor for an svaunit_immediate_assertion_info
     * @param name : instance name for svaunit_immediate_assertion_details object
     */
    function new(input string name = "svaunit_immediate_assertion_info");
        super.new(name);
    endfunction

    /* Get the name of the immediate assertion which is tested
     * @return the name of the immediate assertion which is tested
     */
    function string get_sva_tested_name();
        return sva_tested_name;
    endfunction

    /* Verify that a specific immediate assertion exists into the list
     * @param immediate_assertion : name of the immediate assertion to be found in list
     * @return 1 if the immediate assertion exists and 0 otherwise
     */
    function bit immediate_assertion_exists(string immediate_assertion);
        // Variable used to store the fact that the details exists into list or not
        bit exists = 0;

        foreach(immediate_assertion_details[details_index]) begin
            if(exists == 0) begin
                if(immediate_assertion_details[details_index].get_immediate_assertion_name() == immediate_assertion) begin
                    exists = 1;
                end
            end
        end

        return exists;
    endfunction

    /* Add new detail to a immediate assertion
     * @param immediate_assertion : name of the immediate assertion to be added
     * @param crt_time : current time at which the immediate assertion was tested
     * @param status : status of the current immediate assertion tested
     */
    function void add_new_detail_immediate_assertion(string immediate_assertion, time crt_time, svaunit_status_type status);
        // Variable used to store the fact that the details exists into list or not
        bit exists = 0;

        // Verify for each detail if exists; in this case update detail
        foreach(immediate_assertion_details[details_index]) begin
            if(exists == 0) begin
                if(immediate_assertion_details[details_index].get_immediate_assertion_name() == immediate_assertion) begin
                    immediate_assertion_details[details_index].add_new_detail(crt_time, status);

                    exists = 1;
                end
            end
        end

        // If the detail doesn't exists create a new one
        if(exists == 0) begin
            // Increase the size of details list, create new element and initialize properly
            immediate_assertion_details = new[immediate_assertion_details.size() + 1](immediate_assertion_details);
            immediate_assertion_details[immediate_assertion_details.size() - 1] = svaunit_immediate_assertion_details::type_id::create($sformatf("%s_detail_%s", immediate_assertion, immediate_assertion_details.size() - 1));
            immediate_assertion_details[immediate_assertion_details.size() - 1].create_new_detail_immediat_assertion(immediate_assertion, crt_time, status);
        end
    endfunction

    /* Set new name for SVA
     * @param crt_sva_name : new SVA name to be modified
     */
    function void set_sva_name(string crt_sva_name);
        sva_tested_name = crt_sva_name;
    endfunction

    /* Compute the number of times the immediate assertion was tested and it fails
     * @return the number of times the immediate assertion was tested and it fails
     */
    function int unsigned get_nof_times_sva_failed();
        // Variable used to store the number of times the immediate assertion was tested and it fails
        int unsigned nof_times_assertion_failed = 0;

        // Increase the counter with the number of times the immediate assertion was tested and it fails for each details
        foreach(immediate_assertion_details[details_index]) begin
            nof_times_assertion_failed = nof_times_assertion_failed + (immediate_assertion_details[details_index].get_nof_times_immediate_assertion_tested() - immediate_assertion_details[details_index].get_nof_times_immediate_assertion_pass());
        end

        // Return the number of times the immediate assertion was tested and it fails
        return nof_times_assertion_failed;
    endfunction

    /* Compute the number of times the immediate assertion was tested
     * @return the number of times the immediate assertion was tested
     */
    function int unsigned get_nof_times_sva_tested();
        // Variable used to store the number of times the immediate assertion was tested and it fails
        int unsigned nof_times_assertion_tested = 0;

        // Increase the counter with the number of times the immediate assertion was tested and it fails for each details
        foreach(immediate_assertion_details[details_index]) begin
            nof_times_assertion_tested = nof_times_assertion_tested + immediate_assertion_details[details_index].get_nof_times_immediate_assertion_tested();
        end

        // Return the number of times the immediate assertion was tested and it fails
        return nof_times_assertion_tested;
    endfunction

    /* Form a string with immediate assertions details
     * @return the details of the immediate assertions tested during test
     */
    function string get_immediate_assertion_details();
        // Variable used to store the string to be formed
        string details = "";
        string star = "";
        int unsigned nof_times_sva_tested = get_nof_times_sva_tested();
        int unsigned nof_times_sva_failed = get_nof_times_sva_failed();

        if(nof_times_sva_failed > 0) begin
            star = "*";
        end

        details = $sformatf("%s   %s   %0d/%0d checks PASSED", star, get_sva_tested_name(), nof_times_sva_tested - nof_times_sva_failed, nof_times_sva_tested);

        immediate_assertion_details.rsort(item) with (item.get_nof_times_immediate_assertion_pass() < item.get_nof_times_immediate_assertion_tested());
        // Form string with each detail
        foreach(immediate_assertion_details[details_index]) begin
            details = $sformatf("%s\n\t\t%s", details, immediate_assertion_details[details_index].get_immediate_assertion_detail());
        end

        details = $sformatf("%s\n", details);

        // Return the string
        return details;
    endfunction

    /* Form a string with SVAs which have failed
     * @return the names of the SVAs which have failed during test
     */
    function string get_sva_failed_details();
        // Variable used to store the string to be formed
        string details = "";
        string star = "";
        int unsigned nof_times_sva_tested = get_nof_times_sva_tested();
        int unsigned nof_times_sva_failed = get_nof_times_sva_failed();

        if(nof_times_sva_failed > 0) begin
            star = "*";
            details = $sformatf("%s\t%s   %s", details, star, get_sva_tested_name());
        end

        // Return the string
        return details;
    endfunction

    // Verify if an SVA assertion exists into SVA list
    function bit details_exists(string check_name, string lof_checks[$]);
        if(lof_checks.size() > 0) begin
            foreach(lof_checks[check_index]) begin
                if(lof_checks[check_index] == check_name) begin
                    return 1;
                end
            end
        end

        return 0;
    endfunction

    /* Get a list with immediate assertion names which were used during test
     * @param the string list which contains the name of the checks used in this unit test
     */
    function void get_immediate_assertion_names(ref string immediate_assertions_names[$]);
        foreach(immediate_assertion_details[details_index]) begin
            if(!details_exists(immediate_assertion_details[details_index].get_immediate_assertion_name(), immediate_assertions_names)) begin
                immediate_assertions_names.push_back(immediate_assertion_details[details_index].get_immediate_assertion_name());
            end
        end
    endfunction

    // Print immediate assertions tested in current test
    function void print_immediate_assertion();
        // Variable used to store the string for each detail
        string tested = "";

        `uvm_info("svaunit_immediate_assertion_info", $sformatf("Assertion %s was tested", get_sva_tested_name()), UVM_LOW)

        foreach(immediate_assertion_details[index]) begin
            tested = $sformatf("%s\n %s", tested, immediate_assertion_details[index].get_immediate_assertion_detail());
        end

        `uvm_info("svaunit_immediate_assertion_info", $sformatf("During test was tested: %s", tested), UVM_LOW)
    endfunction

    // Function used to copy the current item into new item
    function svaunit_immediate_assertion_info copy();
        copy = svaunit_immediate_assertion_info::type_id::create("copy_svaunit_immediate_assertion_info");

        copy.sva_tested_name = this.sva_tested_name;

        foreach(this.immediate_assertion_details[index]) begin
            copy.immediate_assertion_details = new[copy.immediate_assertion_details.size() + 1](copy.immediate_assertion_details);
            copy.immediate_assertion_details[copy.immediate_assertion_details.size() - 1] = svaunit_immediate_assertion_details::type_id::create($sformatf("%s_copy_detail_%s", immediate_assertion_details[index].get_immediate_assertion_name(), copy.immediate_assertion_details.size() - 1));
            copy.immediate_assertion_details[copy.immediate_assertion_details.size() - 1] = this.immediate_assertion_details[index].copy();
        end
    endfunction
endclass

`endif

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
 * NAME:        svaunit_test_suite.svh
 * PROJECT:     svaunit
 * Description: svaunit test suite class definition
 *******************************************************************************/

`ifndef __SVAUNIT_TEST_SUITE_SVH
//protection against multiple includes
`define __SVAUNIT_TEST_SUITE_SVH

// svaunit test suite class definition
virtual class svaunit_test_suite extends svaunit_test;

    // List of tests of the current test suite
    svaunit_test lof_tests[$];

    // If 1 the test suite will continue to run if the previous test was failed, if 0 it will be stopped
    bit continue_driving;

    /* Constructor for svaunit_test_suite
     * @param name   : instance name for svaunit_test_suite object
     * @param parent : hierarchical parent for svaunit_test_suite
     */
    function new (string name = "svaunit_test_suite", uvm_component parent);
        super.new(name, parent);

        continue_driving = 1;
    endfunction

    /* Build phase method used to instantiate components
     * @param phase : the phase scheduled for build_phase method
     */
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    /* Set continue driving switch
     * @param crt_continue_driving : value of continue driving
     */
    function void set_continue_driving(bit crt_continue_driving);
        this.continue_driving = crt_continue_driving;
    endfunction

    /* Get continue driving switch value
     * @return the value of continue driving
     */
    function bit get_continue_driving();
        return continue_driving;
    endfunction

    /* Add a given unit test into test list
     * @param crt_test : to be added into the list
     */
    function void add_test(svaunit_test crt_test);
        `uvm_info(get_test_name(), $sformatf("Registering SVA Unit Test %s", crt_test.get_test_name()), UVM_HIGH);
        lof_tests.push_back(crt_test);
    endfunction

    // Update status for a test-suite
    function void update_status();
        int unsigned nof_tests_did_not_run = 0;

        foreach(lof_tests[test_index]) begin
            lof_tests[test_index].update_status();
        end

        nof_tests = get_nof_tests();
        nof_failures = get_nof_tests_failed();
        nof_tests_did_not_run = get_nof_tests_did_not_run();

        super.update_status();
    endfunction

    // {{{ Functions to get test info
    /* Get the tests which ran from current test suite
     * @param tests_ran : list of test which has ran from current test suite
     */
    function void get_ran_tests(ref svaunit_test tests_ran[$]);
        foreach(lof_tests[test_index]) begin
            if(lof_tests[test_index].started()) begin
                tests_ran.push_back(lof_tests[test_index]);
            end
        end
    endfunction

    /* Get the tests which didn't run from current test suite
     * @param tests_ran : list of test which didn't run from current test suite
     */
    function void get_did_not_run_tests(ref svaunit_test tests_ran[$]);
        foreach(lof_tests[test_index]) begin
            if(!(lof_tests[test_index].started())) begin
                tests_ran.push_back(lof_tests[test_index]);
            end
        end
    endfunction

    /* Compute the number of tests from current test suite
     * @return the number of tests from current test suite
     */
    function int unsigned get_nof_tests();
        return lof_tests.size();
    endfunction

    /* Compute the number of tests from current test suite which have failed
     * @return the number of tests from current test suite which have failed
     */
    function int unsigned get_nof_tests_failed();
        int unsigned nof_tests_failed = 0;

        foreach(lof_tests[test_index]) begin
            if(lof_tests[test_index].get_status() == SVAUNIT_FAIL) begin
                nof_tests_failed = nof_tests_failed + 1;
            end
        end

        return nof_tests_failed;
    endfunction

    /* Compute the number of tests from current test suite which did not run
     * @return the number of tests from current test suite which did not run
     */
    function int unsigned get_nof_tests_did_not_run();
        int unsigned nof_tests_did_not_run = 0;

        foreach(lof_tests[test_index]) begin
            if(lof_tests[test_index].get_status() == SVAUNIT_DID_NOT_RUN) begin
                nof_tests_did_not_run = nof_tests_did_not_run + 1;
            end
        end

        return nof_tests_did_not_run;
    endfunction

    /* Compute the number of active tests during simulation for current test suite
     * @return the number of active tests during simulation for current test suite
     */
    function int unsigned get_nof_active_tests();
        // Variable used to store all tests which ran during simulation
        svaunit_test tests_ran[$];

        // Variable used to store the number of active tests during simulation for current test suite
        int unsigned nof_active_tests;

        // Get all tests which ran during simulation
        get_ran_tests(tests_ran);
        nof_active_tests = tests_ran.size();
        tests_ran.delete();

        return nof_active_tests;
    endfunction

    /* Get the tests names as a string
     * @return a string with all tests names from this test suite
     */
    function string get_tests_names();
        // Variable used to store the test_names from this test suite
        string test_names = "";

        // Compute the string with all test names
        foreach(lof_tests[test_index]) begin
            test_names = $sformatf("%s\n\t%s", test_names, lof_tests[test_index].get_test_name());
        end

        return test_names;
    endfunction

    /* Get the tests names which ran as a string
     * @return a string with the tests names which ran from this test suite
     */
    function string get_tests_names_ran();
        // Variable used to store the test_names from this test suite
        string test_names = "";

        // Get all tests which ran during simulation
        svaunit_test tests_ran[$];
        get_ran_tests(tests_ran);

        // Compute the string with all test names
        foreach(tests_ran[test_index]) begin
            test_names = $sformatf("%s\n\t\t%s", test_names, tests_ran[test_index].get_test_name());
        end
        tests_ran.delete();

        return test_names;
    endfunction

    /* Get the tests names which didn't run as a string
     * @return a string with the tests names which didn't run from this test suite
     */
    function string get_tests_names_did_not_run();
        // Variable used to store the test_names from this test suite
        string test_names = "";

        // Get all tests which ran during simulation
        svaunit_test tests_ran[$];
        get_did_not_run_tests(tests_ran);

        // Compute the string with all test names
        foreach(tests_ran[test_index]) begin
            test_names = $sformatf("%s\n\t\t%s", test_names, tests_ran[test_index].get_test_name());
        end
        tests_ran.delete();

        return test_names;
    endfunction
    // }}}

    // {{{ Functions to get SVA info

    /* Get the total number of SVAs tested from all tests
     * @return the total number of SVAs tested from all tests
     */
    function int unsigned get_total_nof_tested_sva();
        // Variable used to store the number of times an SVA was tested
        int unsigned nof_tested_sva = 0;

        foreach(lof_tests[test_index]) begin
            // Get the number of times an SVA was tested
            nof_tested_sva = nof_tested_sva + lof_tests[test_index].get_nof_tested_sva();
        end

        return nof_tested_sva;
    endfunction

    /* Get the names of the SVAs which were tested during test
     * @param tested_sva_names : the names of the SVAs which were tested during test
     */
    function void get_sva_tested_names(ref string tested_sva_names[$]);
        foreach(lof_tests[test_index]) begin
            lof_tests[test_index].get_sva_tested_names(tested_sva_names);
        end
    endfunction

    /* Get the names of the SVAs which were not tested during test
     * @param not_tested_sva_names : the names of the SVAs which were not tested during test
     */
    function void get_sva_not_tested_names(ref string not_tested_sva_names[$]);
        // Variable used to store the names of the SVA which were tested
        string tested_sva_names[$];

        // Variable used to store the names of the SVA which were tested/per test
        string n_tested_sva_names[$];

        foreach(lof_tests[test_index]) begin
            lof_tests[test_index].get_sva_not_tested_names(n_tested_sva_names);
        end

        // Get tested SVAs
        get_sva_tested_names(tested_sva_names);

        // Verify if the SVA not tested from all tests have not been tested into another test
        foreach(n_tested_sva_names[sva_index]) begin
            // Variable used to store the fact that the SVA has been tested or not
            bit exists = 0;

            // Iterate all over the tested SVA names to see if the "NOT tested" SVA list does not contains that SVA name
            foreach(tested_sva_names[index]) begin
                if(tested_sva_names[index] == n_tested_sva_names[sva_index]) begin
                    exists = 1;
                end
            end

            // If it does not exists, verify if that name exists into out list
            if(exists == 0) begin
                // Variable used to store the fact that the SVA name exists into name list
                bit string_exists = 0;

                // Iterate all over the tested SVA names to see if the "NOT tested" SVA list does not contains that SVA name
                foreach(not_tested_sva_names[index]) begin
                    if(not_tested_sva_names[index] == n_tested_sva_names[sva_index]) begin
                        string_exists = 1;
                    end
                end

                // If does not exists, add into names list
                if(string_exists == 0) begin
                    not_tested_sva_names.push_back(n_tested_sva_names[sva_index]);
                end
            end
        end
    endfunction
    // }}}


    // {{{ Function to get checks info

    /* Get a list with all immediate assertions tested into tests
     * @param checks : a list with all immediate assertions tested
     */
    function void get_immediate_assertion();
        // Get the checks used in each test
        foreach(lof_tests[test_index]) begin

            // Iterate all over the immediate assertions used in tests
            foreach(lof_tests[test_index].immediate_assertions[check_index]) begin

                // Will store a copy of current check
                svaunit_immediate_assertion_info check = lof_tests[test_index].immediate_assertions[check_index].copy();

                // Will show that the check exists into check list
                bit check_exists = 0;

                // Iterate all over the immediate assertions from this test suite to see if the sva was tested
                foreach(immediate_assertions[index]) begin
                    // Verify if the current check already exists
                    if(immediate_assertions[index].get_sva_tested_name() == check.get_sva_tested_name()) begin
                        // Set to 1 check_exists because it was found into list
                        check_exists = 1;

                        // Verify if the current check exists a details with that check name
                        foreach(check.immediate_assertion_details[i]) begin
                            // Will store a copy if current detail
                            svaunit_immediate_assertion_details crt_detail = check.immediate_assertion_details[i].copy();

                            // Add new detail to this check
                            for(int j = 0; j < crt_detail.immediate_assertion_time.size(); j++) begin
                                immediate_assertions[index].add_new_detail_immediate_assertion(crt_detail.get_immediate_assertion_name(), crt_detail.immediate_assertion_time[j], crt_detail.immediate_assertions_status[j]);
                            end
                        end
                    end
                end

                // If the check does not exists, insert the check into immediate_assertion list
                if(check_exists == 0) begin
                    immediate_assertions.push_back(check);
                end
            end
        end
    endfunction
    // }}}

    // {{{ Tasks to start testing
    // Task used to start testing - The user should create here scenarios to verify SVAs
    virtual task test();
    endtask

    // Define a behavior that will happens before running the test
    virtual task pre_test();
    endtask

    // Define a behavior that will happens after running the test
    virtual task post_test();
    endtask

    // Pre-run behavior
    task pre_run();
        `uvm_info(get_test_name(), "Start test suite", UVM_HIGH)
        // Raise objection mechanism for this test
        uvm_test_done.raise_objection(this, "", 1);

        // Set start bit
        start_test();
    endtask

    // Post-run behavior
    task post_run();
        `uvm_info(get_test_name(), "End test suite", UVM_HIGH)
        // Raise objection mechanism for this test
        uvm_test_done.drop_objection(this, "", 1);
    endtask

    // Will start the test suite
    task start_ut();
        if(enable == 1) begin
            fork
                begin
                    // Variable used to store the process id for test task
                    process simulate_test_suite;
                    fork
                        begin
                            simulate_test_suite = process::self();
                            fork
                                begin
                                    // Run tests
                                    foreach(lof_tests[test_index]) begin
                                        if(((stop == 0) && (continue_driving == 0)) || (continue_driving == 1)) begin
                                            lof_tests[test_index].start_test();
                                            lof_tests[test_index].set_test_name_vpi(lof_tests[test_index].get_test_name());
                                            lof_tests[test_index].start_ut();
                                            stop = lof_tests[test_index].get_stop();
                                        end
                                    end
                                end

                                begin
                                    while(((stop == 0) && (continue_driving == 0)) || (continue_driving == 1)) begin
                                        #1;
                                    end
                                end
                            join_any
                        end
                    join
                    disable fork;
                    simulate_test_suite.kill();
                end
            join


            // Update status
            update_status();

            // Compact immediate assertions
            get_immediate_assertion();

            // Print report
            print_report();
        end
    endtask

    /* Run phase method used to run test
     * @param phase : the phase scheduled for run_phase method
     */
    virtual task run_phase(uvm_phase phase);
        // Get parent of this test
        uvm_component parent = get_parent();

        // If the test haven't started and it's parent is null, it should start from here
        if(!started() && parent.get_name() == "") begin
            if(enable == 1) begin
                pre_run();

                // Run test body of this test suite
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

                post_run();
            end
        end
    endtask
    // }}}
    
    // {{{ Reports
    /* Get status as a string
     * @return represents the status to be printed
     */
    function string get_status_as_string();
        string report = "";
        string star = " ";

        if(get_status() == SVAUNIT_FAIL) begin
            star = "*";
        end

        report = $sformatf("\n\t%s   %s %s (%0d/%0d test cases PASSED)", star, get_test_name(), status.name(), get_nof_tests() - get_nof_tests_failed() - get_nof_tests_did_not_run(), get_nof_tests());

        return report;
    endfunction

    /* Form the status of the test as a string
     * @return a string which contains the status of test
     */
    function string get_status_tests();
        string report = "";
        string extra = "";

        // Get parent of this test
        uvm_component parent = get_parent();

        // If the test haven't started and it's parent is null, it should start from here
        if(parent.get_name() != "") begin
            extra = $sformatf("%s::", get_type_name());
        end

        report = $sformatf("\n\n-------------------- %s test suite status --------------------\n", get_test_name());
        report = $sformatf("%s\t%s::%s\n", report, get_type_name(), get_test_name());

        foreach(lof_tests[test_index]) begin
            report = {report, "\t\t  ",  lof_tests[test_index].get_status_tests()};
        end

        return report;
    endfunction

    // Print status of test
    function void print_status();
        string report = "";
        string star = " ";

        // Get parent of this test
        uvm_component parent = get_parent();

        if(get_status() == SVAUNIT_FAIL) begin
            star = "*";
        end

        lof_tests.rsort(item) with (item.get_status() == SVAUNIT_FAIL);

        report = $sformatf("\n\n-------------------- %s test suite : Status statistics --------------------\n\n", get_test_name());
        report = $sformatf("%s   %s   %s %s (%0d/%0d test cases PASSED)\n", report, star, get_test_name(), status.name(), nof_tests - nof_failures, nof_tests);

        foreach(lof_tests[test_index]) begin
            report = $sformatf("%s\t%s", report, lof_tests[test_index].get_status_as_string());
        end

        report = $sformatf("%s\n\n", report);

        `uvm_info(get_test_name(), report, UVM_LOW)
    endfunction

    // Print the tests names which ran and the tests names which didn't run during simulation
    function void print_tests();
        // Variable used to store the report string
        string report = "";

        // Variable used to store the number of tests
        int unsigned total_nof_tests = get_nof_tests();

        // Variable used to store the number of active tests
        int unsigned total_nof_tests_active = get_nof_active_tests();

        string tests_did_not_run = get_tests_names_did_not_run();

        // Form report string
        report = $sformatf("\n%s\n\t%0d/%0d Tests ran during simulation", report, total_nof_tests_active, total_nof_tests);
        report = $sformatf("%s\n\t%s\n\n", report, get_tests_names_ran());

        if(tests_did_not_run != "") begin
            report = $sformatf("\n%s\n\t%0d/%0d Tests did not run during simulation", report, total_nof_tests - total_nof_tests_active, total_nof_tests);
            report = $sformatf("%s\n\t%s\n\n", report, tests_did_not_run);
        end

        `uvm_info(get_test_name(), report, UVM_LOW)
    endfunction

    // Print a list with all SVAs and with its status
    function void print_sva();
        // Variable used to store the report string
        string report = "";

        // Variable used to store the SVA names which were tested
        string tested_sva_names[$];

        // Variable used to store the SVA names which were not tested
        string not_tested_sva_names[$];

        // Variable used to store the number of tested SVA
        int unsigned nof_tested_sva;

        // Variable used to store the number of not tested SVA
        int unsigned nof_not_tested_sva;

        get_sva_tested_names(tested_sva_names);
        get_sva_not_tested_names(not_tested_sva_names);

        nof_tested_sva = tested_sva_names.size();
        nof_not_tested_sva = not_tested_sva_names.size();

        // Form report string
        report = $sformatf("\n\n-------------------- %s test suite : SVAs statistics --------------------\n", get_test_name());
        report = $sformatf("%s\n\t%0d/%0d SVA were exercised", report, nof_tested_sva, nof_not_tested_sva + nof_tested_sva);

        foreach(tested_sva_names[index]) begin
            report = $sformatf("%s\n\t\t%s", report, tested_sva_names[index]);
        end

        // Verify if there were SVAs which have not been tested. In this case, in the report will appear also the SVAs which were not tested
        if(nof_not_tested_sva > 0) begin
            report = $sformatf("%s\n\n\t%0d SVA were not exercised", report, nof_not_tested_sva);

            foreach(not_tested_sva_names[index]) begin
                report = $sformatf("%s\n\t\t%s", report, not_tested_sva_names[index]);
            end
        end

        report = $sformatf("%s\n", report);

        `uvm_info(get_test_name(), report, UVM_LOW)
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

        report = $sformatf("\n\n-------------------- %s test suite : Checks statistics --------------------\n\n", get_test_name());
        report = $sformatf("%s\t%0d/%0d Checks were exercised\n\n", report, immediate_assertions_names.size(), immediate_assertions_names.size() + immediate_assertions_not_used_names.size());

        foreach(immediate_assertions_names[index]) begin
            nof_times_immediate_assertion_tested = 0;
            nof_times_immediate_assertion_passed = 0;
            star = " ";
            extra = "";
            nof_times_immediate_assertion_tested = get_nof_times_immediate_assertions_tested(immediate_assertions_names[index]);
            nof_times_immediate_assertion_passed = get_nof_times_immediate_assertions_passed(immediate_assertions_names[index]);

            if(nof_times_immediate_assertion_passed < nof_times_immediate_assertion_tested) begin
                star = "*";
            end

            extra = $sformatf("%0d/%0d times PASSED", nof_times_immediate_assertion_passed, nof_times_immediate_assertion_tested);

            report = $sformatf("%s\t   %s   %s %s \n", report, star, immediate_assertions_names[index], extra);
        end

        if(immediate_assertions_not_used_names.size() > 0) begin
            report = $sformatf("%s\n\t%0d/%0d Checks were not exercised\n\n", report, immediate_assertions_not_used_names.size(), immediate_assertions_names.size() + immediate_assertions_not_used_names.size());

            foreach(immediate_assertions_not_used_names[index]) begin
                report = $sformatf("%s\t\t%s\n", report, immediate_assertions_not_used_names[index]);
            end
        end

        report = $sformatf("%s\n", report);

        `uvm_info(get_test_name(), report, UVM_LOW)
    endfunction

    // Print a report for all checks tested for the SVAs
    function void print_sva_and_checks();
        string report = "";
        svaunit_immediate_assertion_info checks[$];

        report = $sformatf("%s\n\n-------------------- %s test suite : SVA and checks statistics --------------------\n", report, get_test_name());

        foreach(immediate_assertions[index]) begin
            report = $sformatf("%s\n\t%s", report, immediate_assertions[index].get_immediate_assertion_details());
        end

        report = $sformatf("%s\n", report);

        `uvm_info(get_test_name(), report, UVM_LOW)
    endfunction

    // Print a report for all SVA which have failed
    function void print_failed_sva();
        string report = "";
        string details = "";

        report = $sformatf("\n\n-------------------- %s test suite : Failed SVA --------------------\n", get_test_name());

        foreach(immediate_assertions[immediate_assertions_index]) begin
            details = immediate_assertions[immediate_assertions_index].get_sva_failed_details();
            if(details != "") begin
                report = $sformatf("%s\n\t%s", report, immediate_assertions[immediate_assertions_index].get_sva_failed_details());
            end
        end

        report = $sformatf("%s", report);

        `uvm_info(get_test_name(), $sformatf("%s\n", report), UVM_LOW);
    endfunction

    /* Form the tree from test-suites names and tests name
     * @return a string representing the tree
     */
    function string form_tree(int num);
        string extra = "";
        string report = "";

        for(int i = 0; i < num; i++) begin
            extra = {"\t", extra};
        end

        if(num == 0) begin
            extra = {"\t", extra};
        end

        report = {extra, get_test_name()};


        foreach(lof_tests[test_index]) begin
            report = {report, "\n", extra, lof_tests[test_index].form_tree(num + 1)};
        end

        return report;
    endfunction

    // Print report for current test suite
    function void print_report();
        print_tree();
        print_status();
        print_tests();
        print_sva();
        print_checks();
        print_sva_and_checks();
        print_failed_sva();
    endfunction
// }}}
endclass

`endif

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
 * NAME:        svaunit_defines.svh
 * PROJECT:     svaunit
 * Description: Macros used in project
 *******************************************************************************/

`ifndef __SVAUNIT_DEFINES_SVH
//protection against multiple includes
`define __SVAUNIT_DEFINES_SVH

`ifndef SVAUNIT_UTILS
// Define the VPI interface and set it to uvm_config_db
`define SVAUNIT_UTILS \
    import svaunit_pkg::*; \
    import uvm_pkg::*; \
    `include "uvm_macros.svh" \
    svaunit_vpi_interface vpi_if(); \
    initial begin \
        uvm_config_db#(virtual svaunit_vpi_interface)::set(uvm_root::get(), "*", "VPI_VIF", vpi_if); \
    end
`endif

`ifndef SVAUNIT_TEST_WITH_PARAM_UTILS
// Overwrite get_type_name for a parameterizable test
`define SVAUNIT_TEST_WITH_PARAM_UTILS \
    function void set_test_name();\
        int start_index = 0;\
        int end_index = 0;\
\
        test_type = $sformatf("%s@", $typename(this));\
\
        start_index = find(test_type, "::");\
        end_index = find(test_type, ")");\
\
        test_type = test_type.substr(start_index + 2, end_index);\
    endfunction\
    virtual function string get_type_name();\
        return test_type;\
    endfunction
`endif

// --------------------------- SVAUnit checks ---------------------------------------
`ifndef fail_if_sva_enabled
/* Verify if a given SVA is enabled - the test will fail if SVA is enable
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_enabled(assertion_name, error_msg) \
    fail_if_sva_enabled(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_enabled
/* Verify if a given SVA is enabled - the test will pass if SVA is enable
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_enabled(assertion_name, error_msg) \
    pass_if_sva_enabled(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_does_not_exists
/* Verify if a given SVA is exists - the test will fail if SVA is does not exists
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_does_not_exists(assertion_name, error_msg) \
    fail_if_sva_does_not_exists(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_does_not_exists
/* Verify if a given SVA is exists - the test will pass if SVA is does not exists
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_does_not_exists(assertion_name, error_msg) \
    pass_if_sva_does_not_exists(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_succeeded
/* Verify if a given SVA succeeded - the test will fail if SVA succeeded
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_succeeded(assertion_name, error_msg) \
    fail_if_sva_succeeded(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_succeeded
/* Verify if a given SVA succeeded - the test will fail if SVA does not succeeded
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_succeeded(assertion_name, error_msg) \
    pass_if_sva_succeeded(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_not_succeeded
/* Verify if a given SVA didn't succeeded (the assertion should have failed) - the test will fail if the assertion didn't succeeded
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_not_succeeded(assertion_name, error_msg) \
    fail_if_sva_not_succeeded(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_not_succeeded
/* Verify if a given SVA didn't succeeded (the assertion should have failed) - the test will pass if the assertion didn't succeeded
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_not_succeeded(assertion_name, error_msg) \
    pass_if_sva_not_succeeded(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_started_but_not_finished
/* Verify if a given SVA didn't finished  but the first state is START - the test will fail if the assertion didn't finished but the first state is START
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_started_but_not_finished(assertion_name, error_msg) \
    fail_if_sva_started_but_not_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_started_but_not_finished
/* Verify if a given SVA didn't finished  but the first state is START - the test will pass if the assertion didn't finished but the first state is START
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_started_but_not_finished(assertion_name, error_msg) \
    pass_if_sva_started_but_not_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_not_started
/* Verify if a given SVA didn't started - the test will fail if the assertion didn't started
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_not_started(assertion_name, error_msg) \
    fail_if_sva_not_started(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_not_started
/* Verify if a given SVA didn't started - the test will pass if the assertion didn't started
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_not_started(assertion_name, error_msg) \
    pass_if_sva_not_started(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_finished
/* Verify if a given SVA finished - the test will fail if the assertion finished
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_finished(assertion_name, error_msg) \
    fail_if_sva_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_finished
/* Verify if a given SVA finished - the test will pass if the assertion finished
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_finished(assertion_name, error_msg) \
    pass_if_sva_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if_sva_not_finished
/* Verify if a given SVA didn't finished - the test will fail if the assertion didn't finished
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if_sva_not_finished(assertion_name, error_msg) \
    fail_if_sva_not_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if_sva_not_finished
/* Verify if a given SVA didn't finished - the test will pass if the assertion didn't finished
 * @param assertion_name : assertion name to be found in SVA list
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if_sva_not_finished(assertion_name, error_msg) \
    pass_if_sva_not_finished(assertion_name, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef fail_if
/* Verify if the expression is FALSE - the test will fail if the expression is FALSE
 * @param expression : the expression to be checked
 * @param error_msg : user error message to be printed if the check fails
 */
`define fail_if(expression, error_msg) \
    fail_if(expression, error_msg, `uvm_line, `uvm_file);
`endif

`ifndef pass_if
/* Verify if the expression is FALSE - the test will pass if the expression is FALSE
 * @param expression : the expression to be checked
 * @param error_msg : user error message to be printed if the check fails
 */
`define pass_if(expression, error_msg) \
    pass_if(expression, error_msg, `uvm_line, `uvm_file);
`endif

// --------------------------- MACROS INDEX ---------------------------------------

`ifndef SVAUNIT_START_STATE_INDEX
// Define the start index for state list
`define SVAUNIT_START_STATE_INDEX 0
`endif


`ifndef SVAUNIT_END_STATE_INDEX
// Define the end index for state list
`define SVAUNIT_END_STATE_INDEX 1
`endif

// ---------------------------- Assertion callback types ---------------------------------
`ifndef SVAUNIT_VPI_CB_ASSERTION_START
// Define the assertion callback for START. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_START 606
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_SUCCESS
// Define the assertion callback for SUCCESS. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_SUCCESS 607
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_FAILURE
// Define the assertion callback for FAILURE. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_FAILURE 608
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_STEP_SUCCESS
// Define the assertion callback for STEP SUCCESS. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_STEP_SUCCESS 609
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_STEP_FAILURE
// Define the assertion callback for STEP FAILURE. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_STEP_FAILURE 610
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_DISABLE
// Define the assertion callback for DISABLE. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_DISABLE 611
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_ENABLE
// Define the assertion callback for ENABLE. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_ENABLE 612
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_RESET
// Define the assertion callback for RESET. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_RESET 613
`endif

`ifndef SVAUNIT_VPI_CB_ASSERTION_KILL
// Define the assertion callback for KILL. The index value is specified by VPI.
`define SVAUNIT_VPI_CB_ASSERTION_KILL 614
`endif

//------------------------------- Assertion control --------------------------------
`ifndef SVAUNIT_VPI_CONTROL_RESET_ASSERTION
// Define assertion control constant for RESET. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_RESET_ASSERTION 622
`endif

`ifndef SVAUNIT_VPI_CONTROL_DISABLE_ASSERTION
// Define assertion control constant for DIASBLE. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_DISABLE_ASSERTION 620
`endif

`ifndef SVAUNIT_VPI_CONTROL_ENABLE_ASSERTION
// Define assertion control constant for ENABLE. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_ENABLE_ASSERTION 621
`endif

`ifndef SVAUNIT_VPI_CONTROL_KILL_ASSERTION
// Define assertion control constant for KILL. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_KILL_ASSERTION 623
`endif

`ifndef SVAUNIT_VPI_CONTROL_DISABLE_STEP_ASSERTION
// Define assertion control constant for DIASBLE STEP. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_DISABLE_STEP_ASSERTION 625
`endif

`ifndef SVAUNIT_VPI_CONTROL_ENABLE_STEP_ASSERTION
// Define assertion control constant for ENABLE STEP. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_ENABLE_STEP_ASSERTION 624
`endif

//------------------------------- Assertion system control --------------------------------
`ifndef SVAUNIT_VPI_CONTROL_SYSTEM_RESET_ASSERTION
// Define assertion control constant for SYSTEM RESET. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_SYSTEM_RESET_ASSERTION 630
`endif

`ifndef SVAUNIT_VPI_CONTROL_SYSTEM_ON_ASSERTION
// Define assertion control constant for SYSTEM ON. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_SYSTEM_ON_ASSERTION 627
`endif

`ifndef SVAUNIT_VPI_CONTROL_SYSTEM_OFF_ASSERTION
// Define assertion control constant for SYSTEM OFF. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_SYSTEM_OFF_ASSERTION 628
`endif

`ifndef SVAUNIT_VPI_CONTROL_SYSTEM_END_ASSERTION
// Define assertion control constant for SYSTEM END. The index value is specified by VPI.
`define SVAUNIT_VPI_CONTROL_SYSTEM_END_ASSERTION 629
`endif

`endif

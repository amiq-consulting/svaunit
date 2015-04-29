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
 * MODULE:       svaunit_vpi_api.cpp
 * PROJECT:      svaunit
 * Description:  VPI APIs and DPI-C API - retrieve informations about SVA using VPI
 *               and transfer the information to/from SystemVerilog
 *******************************************************************************/

#ifndef __SVAUNIT_VPI_API_CPP
//protection against multiple includes
#define __SVAUNIT_VPI_API_CPP

#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <stdio.h>
#include <vector>

#include "svdpi.h"
#include "sv_vpi_user.h"
#include "vpi_user.h"

using namespace std;

// Class used to store callback info
class cb_assertion_info {
public:
	// SVA name
	string assertion_name;

	// SVA type
	string assertion_type;

	// The reason why this callback was triggered
	int reason;

	// The start time of the SVA attempt
	int start_time;

	// Callback time
	int cb_time;
public:
	/* Constructor for callback info
	 * name : SVA name
	 * type : SVA type
	 * cb_reason : current reason why this callback was triggered
	 * cb_start_time : current start time of the SVA attempt
	 * a_cb_time : callback time
	 */
	cb_assertion_info(string name, string type, int cb_reason,
			int cb_start_time, int a_cb_time) {

		assertion_name = name;
		assertion_type = type;
		reason = cb_reason;
		start_time = cb_start_time;
		cb_time = a_cb_time;
	}

	// Destructor for callback info class
	~cb_assertion_info() {
	}
};

extern "C" {

/* VPI API to update a given SVA
 * crt_test_name : test name from where this function is called
 * assertion_name : SVA name to be updated
 * assertion_type : the type of the SVA to be updated
 * reason : callback reason
 * start_time : the start attempt for this SVA
 * callback_time : the callback time for this SVA attempt
 */
extern void pass_info_to_sv(char *, char *, char *, int, int, int);

/* Create SVA with a name and a type given
 * assertion_name : SVA name to be created
 * assertion_type : SVA type to be created
 */
extern void create_assertion(char *, char *);
//the SV scope saved at assertion registration. this is required in order to
//set a scope once the assertion callbacks are ready to update information in SV
svScope testSvScope;

// List of SVAs which where found using VPI API
std::vector<vpiHandle> lof_assertions;

// List of callbacks for SVAs - this list will store the callbacks until a DPI-C call came
std::vector<cb_assertion_info> lof_cbs;

// Test name
char * test_name;

/* Set the current test_name
 * crt_test_name : current test name to be updated
 */
void set_test_name_to_vpi(char * crt_test_name) {
	test_name = crt_test_name;
}

/* Convert a string from a given char*
 * a_string : the string to be converted
 * return the converted char*
 */
char * get_char_from_string(string a_string) {
	char **a_string_c = new char *[1];

	a_string_c[0] = new char[a_string.length() + 1];

	strcpy(a_string_c[0], a_string.c_str());

	return a_string_c[0];
}

/* Control assertion using vpi_control function
 * assertion_name : the assertion used to apply control action on
 * control_type : the control action
 * sys_time : attempt time
 */
void control_assertion(char * assertion_name, int control_type, int sys_time) {
	string assertion_type;
	s_vpi_time *a_struct;
	int step_constant;
	bool running_cadence = 0;

#ifndef IRUN
	running_cadence = 0;
#else
	running_cadence = 1;
#endif

	if (((running_cadence == 0)
			&& ((control_type == vpiAssertionEnableStep)
					|| (control_type == vpiAssertionDisableStep)))
			|| (control_type == vpiAssertionKill)) {
		a_struct->type = vpiSimTime;
		a_struct->high = 0;
		a_struct->low = 0;
		a_struct->real = 0;
	}

	if ((running_cadence == 0)
			&& ((control_type == vpiAssertionEnableStep)
					|| (control_type == vpiAssertionDisableStep))) {
		step_constant = vpiAssertionClockSteps;
	}

	if ((control_type == vpiAssertionReset)
			|| (control_type == vpiAssertionDisable)
			|| (control_type == vpiAssertionEnable)
			|| (control_type == vpiAssertionKill)
			|| ((running_cadence == 0)
					&& ((control_type == vpiAssertionEnableStep)
							|| (control_type == vpiAssertionDisableStep)))) {
		if (lof_assertions.size() > 0) {
			for (unsigned int sva_index = 0; sva_index < lof_assertions.size();
					sva_index++) {

				vpiHandle assertion = lof_assertions[sva_index];
				string an_assertion_name = vpi_get_str(vpiName, assertion);

				if ((an_assertion_name.compare(assertion_name) == 0)
						&& ((vpi_get(vpiType, assertion) != vpiPropertyDecl)
								|| (vpi_get(vpiType, assertion)
										!= vpiPropertyInst))) {
					vpi_control(control_type, assertion, &a_struct,
							step_constant);
				}
			}
		}
	} else if ((control_type == vpiAssertionSysReset)
			|| (control_type == vpiAssertionSysOn)
			|| (control_type == vpiAssertionSysOff)
			|| (control_type == vpiAssertionSysEnd)) {
		vpi_control(control_type);
	}
}

/* Assertion callback function
 * reason : callback reason
 * cb_time : callback time
 * assertion : handle to assertion
 * info : attempt related information
 * user_data : user data entered upon registration
 * return the callback reason
 */
PLI_INT32 assertion_callback(PLI_INT32 reason, p_vpi_time cb_time,
		vpiHandle assertion, p_vpi_attempt_info info, PLI_BYTE8 *user_data) {

	string casted_reason = "UNKNOWN";
	int callback_time;
	int start_time;
	string assertion_name = vpi_get_str(vpiName, assertion);
	string assertion_full_name = vpi_get_str(vpiFullName, assertion);

	string assertion_type = vpi_get_str(vpiType, assertion);

	if (reason == cbAssertionStart) {
		casted_reason = "START";
	} else if (reason == cbAssertionSuccess) {
		casted_reason = "SUCCESS";
	} else if (reason == cbAssertionFailure) {
		casted_reason = "FAILURE";
	} else if (reason == cbAssertionDisable) {
		casted_reason = "DISABLE";
	} else if (reason == cbAssertionEnable) {
		casted_reason = "ENABLE";
	} else if (reason == cbAssertionReset) {
		casted_reason = "RESET";
	} else if (reason == cbAssertionKill) {
		casted_reason = "KILL";
	} else {
		casted_reason = "IDLE";

		// For Cadence cbAssertionStepSuccess and cbAssertionStepFailure are not supported
#ifndef IRUN
		if (reason == cbAssertionStepSuccess) {
			casted_reason = "STEP_SUCCESS";
		} else if (reason == cbAssertionStepFailure) {
			casted_reason = "STEP_FAILURE";
		}
#endif
	}

	if (cb_time != NULL) {
		if (cb_time->type == vpiScaledRealTime) {
			callback_time = (int) (cb_time->real);
		} else if (cb_time->type == vpiSimTime) {
			callback_time = (int) (cb_time->low);
		}
	} else {
		callback_time = 0;
	}

	if (info != NULL) {
		if (info->attemptStartTime.type == vpiScaledRealTime) {
			start_time = (int) (info->attemptStartTime.real);
		} else if (info->attemptStartTime.type == vpiSimTime) {
			start_time = (int) (info->attemptStartTime.low);
		}
	} else {
		start_time = callback_time;
	}

//	printf(
//			"Detected assertion callback -> name: %s, reason: %s, time: %d, start_time : %d \n",
//			assertion_full_name.c_str(), casted_reason.c_str(), callback_time,
//			start_time);

	cb_assertion_info crt_callback_info(assertion_name, assertion_type, reason,
			callback_time, start_time);

	lof_cbs.push_back(crt_callback_info);

	return reason;
}

/* DPI-C API to retrieve information about all callbacks
 * crt_test_name : the test name from which this function is called
 */
void call_callback(char * crt_test_name) {
//set the scope as this function is a callback and in SV there is no scope set
	svSetScope(testSvScope);

	while (lof_cbs.size() > 0) {
		pass_info_to_sv(crt_test_name,
				get_char_from_string(lof_cbs[0].assertion_name),
				get_char_from_string(lof_cbs[0].assertion_type),
				lof_cbs[0].reason, lof_cbs[0].start_time, lof_cbs[0].cb_time);

		lof_cbs.erase(lof_cbs.begin());
	}

}

/* Place callbacks on a given SVA
 * assertion : handle to assertion
 */
void put_callbacks_on_assertion(vpiHandle assertion) {
	string assertion_name = vpi_get_str(vpiName, assertion);
	bool running_cadence = 0;

// Verify if the current simulator is from Cadence
#ifndef IRUN
	running_cadence = 0;
#else
	running_cadence = 1;
#endif

	printf("Set callback on assertion: %s \n", assertion_name.c_str());

	PLI_BYTE8 *user_data = (PLI_BYTE8 *) 0;

	if (((vpi_get(vpiType, assertion) != vpiPropertyDecl)
			&& (running_cadence == 1)) || (running_cadence == 0)) {
		// For Cadence there could not be a callback on vpiPropertyDecl
		vpi_register_assertion_cb(assertion, cbAssertionStart,
				assertion_callback, user_data);
	}

	if (((vpi_get(vpiType, assertion) != vpiPropertyDecl)
			&& (running_cadence == 1)) || (running_cadence == 0)) {
		vpi_register_assertion_cb(assertion, cbAssertionFailure,
				assertion_callback, user_data);
		vpi_register_assertion_cb(assertion, cbAssertionSuccess,
				assertion_callback, user_data);
		vpi_register_assertion_cb(assertion, cbAssertionDisable,
				assertion_callback, user_data);
		vpi_register_assertion_cb(assertion, cbAssertionEnable,
				assertion_callback, user_data);
		vpi_register_assertion_cb(assertion, cbAssertionReset,
				assertion_callback, user_data);
		vpi_register_assertion_cb(assertion, cbAssertionKill,
				assertion_callback, user_data);

		if (running_cadence == 0) {
			// For Cadence cbAssertionStepSuccess and cbAssertionStepFailure are not supported
			vpi_register_assertion_cb(assertion, cbAssertionStepSuccess,
					assertion_callback, user_data);
			vpi_register_assertion_cb(assertion, cbAssertionStepFailure,
					assertion_callback, user_data);
		}
	}
}

// DPI-C API used to find SVAs using VPI API
void register_assertions() {
	testSvScope = svGetScope();

	svSetScope(testSvScope);

	printf("Register assertions!\n");

	std::vector<vpiHandle> lof_assertions_units;

	//get an iterator over all assertions
	vpiHandle itr_top, itr_interface, itr_sva, itr_param, itr_gen_scope,
			itr_gen;

	//handle for current assertion
	vpiHandle top_module, interface, sva, param, generate, scope_handle;

	string assertion_name, assertion_type;

	// Test runners
	if ((itr_top = vpi_iterate(vpiModule, NULL)) != NULL) {
		while ((top_module = vpi_scan(itr_top)) != NULL) {

			if ((itr_gen_scope = vpi_iterate(vpiInternalScope, top_module))
					!= NULL) {
				while ((generate = vpi_scan(itr_gen_scope)) != NULL) {

					if (vpi_get(vpiType, generate) == vpiGenScope) {
						if ((itr_interface = vpi_iterate(vpiInternalScope,
								generate)) != NULL) {
							while ((interface = vpi_scan(itr_interface)) != NULL) {

								if (vpi_get(vpiType, interface) == vpiInterface) {
									lof_assertions_units.push_back(interface);
								}
							}
						}
					}
				}
			}
			if ((itr_gen_scope = vpi_iterate(vpiGenScopeArray, top_module))
					!= NULL) {
				while ((generate = vpi_scan(itr_gen_scope)) != NULL) {

					if ((itr_gen = vpi_iterate(vpiGenScope, generate)) != NULL) {
						while ((scope_handle = vpi_scan(itr_gen)) != NULL) {

							if ((itr_interface = vpi_iterate(vpiInterface,
									scope_handle)) != NULL) {
								while ((interface = vpi_scan(itr_interface))
										!= NULL) {
									lof_assertions_units.push_back(interface);
								}
							}
						}
					}
				}
			}

			if ((itr_interface = vpi_iterate(vpiInterface, top_module)) != NULL) {
				while ((interface = vpi_scan(itr_interface)) != NULL) {
					lof_assertions_units.push_back(interface);
				}
			}

			if ((itr_interface = vpi_iterate(vpiModule, top_module)) != NULL) {
				while ((interface = vpi_scan(itr_interface)) != NULL) {
					lof_assertions_units.push_back(interface);
				}
			}
			if ((itr_interface = vpi_iterate(vpiProgram, top_module)) != NULL) {
				while ((interface = vpi_scan(itr_interface)) != NULL) {
					lof_assertions_units.push_back(interface);
				}
			}
		}
	}

	for (int unsigned index = 0; index < lof_assertions_units.size(); index++) {
		if ((itr_param = vpi_iterate(vpiParameter, lof_assertions_units[index]))
				!= NULL) {
			while ((param = vpi_scan(itr_param)) != NULL) {
				struct t_vpi_value argval;
				int value;

				argval.format = vpiIntVal;
				vpi_get_value(param, &argval);
				value = argval.value.integer;
				printf("VPI routine received %d\n", value);
			}
		}

		if (svGetNameFromScope(testSvScope)
				!= vpi_get_str(vpiFullName, lof_assertions_units[index])) {

			if ((itr_sva = vpi_iterate(vpiAssertion,
					lof_assertions_units[index])) != NULL) {
				while ((sva = vpi_scan(itr_sva)) != NULL) {
					lof_assertions.push_back(sva);
				}
			}
		}
	}

	for (unsigned int sva_index = 0; sva_index < lof_assertions.size();
			sva_index++) {
		assertion_name = vpi_get_str(vpiName, lof_assertions[sva_index]);
		assertion_type = vpi_get_str(vpiType, lof_assertions[sva_index]);

		printf("Registering assertion: %s with type: %s\n",
				assertion_name.c_str(), assertion_type.c_str());


		//send information to SV
		create_assertion(get_char_from_string(assertion_name),
				get_char_from_string(assertion_type));

		put_callbacks_on_assertion(lof_assertions[sva_index]);
	}
}

/* DPI-C API used to get SVA cover statistics - how many times this cover was triggered and how many times it failed
 * cover_name : cover name to retrieve information about
 * nof_attempts_failed_covered : number of attempts this cover was triggered and it failed
 * nof_attempts_succeeded_covered : number of attempts this cover was triggered and it succeeded
 */
void get_cover_statistics(char * cover_name, int * nof_attempts_failed_covered,
		int * nof_attempts_succeeded_covered) {

	for (unsigned int i = 0; i < lof_assertions.size(); i++) {

		string assertion_name = vpi_get_str(vpiName, lof_assertions[i]);

		if (assertion_name.compare(cover_name) == 0) {
			if (vpi_get(vpiType, lof_assertions[i]) == vpiCover) {

				*nof_attempts_failed_covered = vpi_get(
				vpiAssertFailureCovered, lof_assertions[i]);
				*nof_attempts_succeeded_covered = vpi_get(
				vpiAssertSuccessCovered, lof_assertions[i]);
			}
		}
	}
}

}

#endif

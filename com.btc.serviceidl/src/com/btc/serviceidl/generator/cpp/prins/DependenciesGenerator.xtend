/*********************************************************************
 * \author see AUTHORS file
 * \copyright 2015-2018 BTC Business Technology Consulting AG and others
 * 
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 * 
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/
package com.btc.serviceidl.generator.cpp.prins

import com.btc.serviceidl.generator.common.ParameterBundle
import com.btc.serviceidl.generator.common.ProjectType
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(NONE)
class DependenciesGenerator
{
    val Iterable<String> externalDependencies
    val ParameterBundle paramBundle

    def generate()
    {
        val effectiveDependencies = externalDependencies.toSet

        // proxy and dispatcher include a *.impl.h file from the Protobuf project
        // for type-conversion routines; therefore some hidden dependencies
        // exist, which are explicitly resolved here
        if (paramBundle.projectType == ProjectType.PROXY || paramBundle.projectType == ProjectType.DISPATCHER)
        {
            effectiveDependencies.add("BTC.CAB.Commons.FutureUtil.lib")
        }

        if (paramBundle.projectType == ProjectType.PROTOBUF || paramBundle.projectType == ProjectType.DISPATCHER ||
            paramBundle.projectType == ProjectType.PROXY || paramBundle.projectType == ProjectType.SERVER_RUNNER)
        {
            effectiveDependencies.add("libprotobuf.lib")
        }

        // TODO why are the #pragma directives encapsulated within CAB header guards? I can't imagine any effect they could have on the directives
        '''
            «FOR lib : effectiveDependencies.sort 
             BEFORE '''#include "modules/Commons/include/BeginCabInclude.h"  // CAB -->''' + System.lineSeparator 
             AFTER '''#include "modules/Commons/include/EndCabInclude.h"    // CAB <--''' + System.lineSeparator»
                #pragma comment(lib, "«lib»")
            «ENDFOR»
        '''

    }
}

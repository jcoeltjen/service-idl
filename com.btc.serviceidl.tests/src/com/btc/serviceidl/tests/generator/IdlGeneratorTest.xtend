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
package com.btc.serviceidl.tests.generator

import com.btc.serviceidl.FileSystemAccessWrapper
import com.btc.serviceidl.generator.DefaultGenerationSettingsProvider
import com.btc.serviceidl.generator.IGenerationSettingsProvider
import com.btc.serviceidl.idl.IDLSpecification
import com.btc.serviceidl.tests.IdlInjectorProvider
import com.btc.serviceidl.tests.testdata.TestData
import com.google.inject.Inject
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static com.btc.serviceidl.tests.TestExtensions.*
import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(IdlInjectorProvider)
class IdlGeneratorTest
{
    @Inject extension ParseHelper<IDLSpecification>
    @Inject IGenerator2 underTest
    @Inject IGenerationSettingsProvider generationSettingsProvider

    private def doGenerate(CharSequence input)
    {
        val defaultGenerationSettingsProvider = generationSettingsProvider as DefaultGenerationSettingsProvider
        defaultGenerationSettingsProvider.reset() // TODO remove this, it is necessary because the dependencies are reused across test cases        
        val spec = input.parse
        val baseFsa = new InMemoryFileSystemAccess()
        val fsa = new FileSystemAccessWrapper[baseFsa]
        val generatorContext = new GeneratorContext()
        underTest.doGenerate(spec.eResource, fsa, generatorContext)
        println(baseFsa.textFiles.keySet.join("\n"))
        baseFsa
    }

    @Test
    def void testBasic()
    {
        val fsa = doGenerate(TestData.basic)
        assertEquals(116, fsa.textFiles.size)
    }

    @Test
    def void testFull()
    {
        val fsa = doGenerate(TestData.full)
        assertEquals(145, fsa.textFiles.size)
    }

    @Test
    def void testEvent()
    {
        val fsa = doGenerate(TestData.eventTestCase)
        assertEquals(121, fsa.textFiles.size)
    }

    @Test
    def void testGenerationSmokeTest()
    {
        doForEachTestCase(
            TestData.goodTestCases,
            [ testCase |
                doGenerate(testCase.value)
                #[]
            ]
        )
    }

}

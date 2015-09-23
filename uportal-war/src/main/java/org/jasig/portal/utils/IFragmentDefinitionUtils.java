/**
 * Licensed to Apereo under one or more contributor license
 * agreements. See the NOTICE file distributed with this work
 * for additional information regarding copyright ownership.
 * Apereo licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License.  You may obtain a
 * copy of the License at the following location:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.jasig.portal.utils;

import java.util.Collection;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import org.jasig.portal.layout.dlm.FragmentDefinition;
import org.jasig.portal.layout.dlm.UserView;
import org.jasig.portal.security.IPerson;
import org.w3c.dom.Document;

/**
 * Interface for classes providing utility methods for dealing with {@link FragmentDefinition}s.
 */
public interface IFragmentDefinitionUtils {

    /**
     * Returns list of all fragment definitions.
     * @return list of fragment definitions
     */
    List<FragmentDefinition> getFragmentDefinitions();

    /**
     * Returns fragment definition for the fragment specified by the fragment name.
     * @param fragmentName specifies desired fragment
     * @return fragment definition specified by fragmentName, if found; null otherwise
     */
    FragmentDefinition getFragmentDefinitionByName(final String fragmentName);

    /**
     * Returns the fragment definition for the fragment owned by the person indicated.
     * @param person person who owns the fragment
     * @return fragment definition for fragment owned by the specified person, if found; null otherwise
     */
    FragmentDefinition getFragmentDefinitionByOwner(final IPerson person);

    /**
     * Returns the fragment definition for the fragment owned by the person identified by the owner ID.
     * @param ownerId ID for person who owns the fragment
     * @return fragment definition for fragment owned by the specified person, if found; null otherwise
     */
    FragmentDefinition getFragmentDefinitionByOwner(final String ownerId);

    /**
     * Returns the list of fragment definitions for fragments that are "applicable" to a person.
     * @see FragmentDefinition#isApplicable(IPerson)
     * @param person person for whom applicable fragment definitions are desired
     * @return list of fragment definitions applicable to the person; empty list if none are applicable
     */
    List<FragmentDefinition> getFragmentDefinitionsApplicableToPerson(final IPerson person);

    /**
     * Returns the list of all {@link UserView}s for the specified {@link Locale}.
     * @param locale locale for user views requested
     * @return list of user views for given locale
     */
    List<UserView> getFragmentDefinitionUserViews(final Locale locale);

    /**
     * Returns the list of all {@link UserView}s for the specified {@link FragmentDefinition} and {@link Locale}.
     * @param fragmentDefinitions fragment definitions for user views requested
     * @param locale locale for user view requested
     * @return list of user views for given fragment definitions and locale
     */
    List<UserView> getFragmentDefinitionUserViews(final List<FragmentDefinition> fragmentDefinitions, final Locale locale);

    /**
     * Returns the list of layout documents for all {@link UserView}s for the specified {@link FragmentDefinition} and {@link Locale}.
     * @param fragmentDefinitions fragment definitions for user view layouts requested
     * @param locale locale for user view layouts requested
     * @return list of user view layout documents for given fragment definitions and locale
     */
    List<Document> getFragmentDefinitionUserViewLayouts(final List<FragmentDefinition> fragmentDefinitions, final Locale locale);

    /**
     * Returns names of all known fragments.
     * @return set of names for all known fragments
     */
    Set<String> getFragmentNames();

    /**
     * For the specified list of fragment definitions, collects the fragment names and returns them in a set.
     * @param fragmentDefinitions fragment definitions for fragments whose names will be returned
     * @return set containing names for fragments specified by the input list of fragment definitions
     */
    Set<String> getFragmentNames(final Collection<FragmentDefinition> fragmentDefinitions);

    /**
     * Returns the {@link UserView} for the specified {@link FragmentDefinition} and {@link Locale}.
     * @param fragmentDefinition fragment definition for user view requested
     * @param locale locale for user view requested
     * @return user view for given fragment definition and locale, if found; null otherwise
     */
    UserView getUserView(final FragmentDefinition fragmentDefinition, final Locale locale);

}
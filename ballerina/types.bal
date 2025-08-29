// Copyright (c) 2025 WSO2 LLC (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/ai;

# Represents the configuration options for interacting with a Pinecone vector store.
public type Configuration record {
    # Optional namespace to isolate vectors within Pinecone
    string namespace?;
    # Metadata filters applied during search
    ai:MetadataFilters filters?;
    # Optional sparse vector for hybrid search operations
    ai:SparseVector sparseVector?;
};

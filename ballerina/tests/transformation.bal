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
import ballerina/test;
import ballerinax/pinecone.vector;

@test:Config
isolated function testTransformMetadata() {
    ai:Metadata metadata = {createdAt: [1758793007, 0.798845]};
     map<anydata> transformedMetadata = transformMetadata(metadata);
    vector:VectorMetadata expecectedMetadata = {"createdAt": "2025-09-25T09:36:47.798845Z"};
    test:assertEquals(expecectedMetadata, transformedMetadata);
}

@test:Config
isolated function testCreateAiMetadata() returns error? {
    vector:VectorMetadata vectorMetadata = {"createdAt": "2025-09-25T09:36:47.798845Z"};
    ai:Metadata? metadata = check createAiMetadata(vectorMetadata);
    ai:Metadata expecectedMetadata = {createdAt: [1758793007, 0.798845]};
    test:assertEquals(expecectedMetadata, metadata);
}

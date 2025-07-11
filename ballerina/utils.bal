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
import ballerina/uuid;
import ballerinax/pinecone.vector;

# Converts standard comparison operators to Pinecone filter operators
#
# + operator - The standard operator to convert (!=, ==, >, <, >=, <=, in, nin)
# + return - The corresponding Pinecone operator string or an error if unsupported
isolated function mapPineconeOperator(ai:MetadataFilterOperator operator) returns string|ai:Error {
    match operator {
        ai:NOT_EQUAL => {
            return "$ne"; 
        }
        ai:EQUAL => {
            return "$eq"; 
        }
        ai:GREATER_THAN => {
            return "$gt"; 
        }
        ai:LESS_THAN => {
            return "$lt"; 
        }
        ai:GREATER_THAN_OR_EQUAL => {
            return "$gte"; 
        }
        ai:LESS_THAN_OR_EQUAL => {
            return "$lte"; 
        }
        ai:IN => {
            return "$in"; 
        }
        ai:NOT_IN => {
            return "$nin"; 
        }
        _ => {
            return error(string `Unsupported filter operator: ${operator}`);
        }
    }
}

# Converts logical condition operators to Pinecone condition operators
#
# + condition - The logical condition to convert (and, or)
# + return - The corresponding Pinecone condition string or an error if unsupported
isolated function mapPineconeCondition(ai:MetadataFilterCondition condition) returns string|ai:Error {
    match condition {
        ai:AND => {
            return "$and"; 
        }
        ai:OR => {
            return "$or"; 
        }
        _ => {
            return error(string `Unsupported filter condition: ${condition}`);
        }
    }
}

# Converts metadata filters to Pinecone compatible filter format
#
# + filters - The metadata filters containing filter conditions and logical operators
# + return - A map representing the converted filter structure or an error if conversion fails
isolated function convertPineconeFilters(ai:MetadataFilters filters) returns map<anydata>|ai:Error {
    (ai:MetadataFilters|ai:MetadataFilter)[]? rawFilters = filters.filters;

    if rawFilters == () || rawFilters.length() == 0 {
        return {};
    }

    map<anydata>[] filterList = [];

    foreach (ai:MetadataFilters|ai:MetadataFilter) filter in rawFilters {
        if filter is ai:MetadataFilter {
            map<anydata> filterMap = {};

            if filter.operator == ai:EQUAL {
                filterMap[filter.key] = filter.value;
                filterList.push(filterMap);
                continue;
            }

            string pineconeOp = check mapPineconeOperator(filter.operator);
            map<anydata> operatorMap = { [pineconeOp]: filter.value };
            filterMap[filter.key] = operatorMap;
            filterList.push(filterMap);
            continue;
        }

        map<anydata> nestedFilter = check convertPineconeFilters(filter);
        if nestedFilter.length() > 0 {
            filterList.push(nestedFilter);
        }
    }

    if filterList.length() == 0 {
        return {};
    } 
    if filterList.length() == 1 {
        return filterList[0];
    } 
    string pineconeCondition = check mapPineconeCondition(filters.condition);
    map<anydata> result = {[pineconeCondition]: filterList};
    return result;
}


# Extracts the content from the metadata
#
# + metadata - The metadata map that may contain content
# + return - The content as a string, or a default message if not found
isolated function getContent(map<anydata>? metadata) returns string {
    if metadata is () {
        return "No metadata provided";
    }

    anydata content = metadata["content"];
    if content is string {
        return content;
    } 
    if content is () {
        return "Content field not found in metadata";
    } 
    return "Content field is not a string: " + content.toString();
}

# Converts a VectorEntry to a Vector based on the specified query mode.
#
# + entry - The VectorEntry to convert
# + queryMode - The query mode to determine how to convert the entry
# 
# + return - A Vector object containing the ID, values, sparseValues, and metadata
# or an error if the conversion fails
isolated function mapEntryToVector(ai:VectorEntry entry, ai:VectorStoreQueryMode queryMode) returns vector:Vector|ai:Error {
    map<anydata> metadata = entry.chunk?.metadata ?: {};
    metadata["content"] = entry.chunk.content;
    ai:Embedding embedding = entry.embedding;

    if entry.id is () {
        entry.id = uuid:createRandomUuid();
    }

    if queryMode == ai:DENSE {
        if embedding is ai:Vector {
            return {
                id: entry.id,
                values: embedding,
                metadata
            };
        }
        return error("Dense mode requires DenseVector embedding.");
    } 
    if queryMode == ai:SPARSE {
        if embedding is ai:SparseVector {
            return {
                id: entry.id,
                sparseValues: embedding,
                metadata
            };
        }
        return error ("Sparse mode requires SparseVector embedding.");
    } 
    if queryMode == ai:HYBRID {
        if embedding is ai:HybridVector {
            if embedding.dense.length() == 0 && embedding.sparse.indices.length() == 0 {
                return error("Hybrid mode requires both dense and sparse vectors, but one or both are missing.");
            }
            return {
                id: entry.id,
                values: embedding.dense,
                sparseValues: embedding.sparse,
                metadata
            };
        }
        return error("Hybrid mode requires DenseVector and SparseVector embedding.");
    } 
}


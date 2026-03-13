## Overview

Pinecone is a fully managed vector database that makes it easy to build high-performance vector search applications. The Pinecone connector provides an API to interact with Pinecone indexes, enabling efficient management and search of vector embeddings in the cloud.

### Key Features

- Fully managed vector database for high-performance search
- Efficient management of indexes and namespaces
- High-speed vector similarity search with metadata filtering
- Reliable and scalable cloud-native infrastructure
- Secure communication with API key authentication
- GraalVM compatible for native image builds

## Prerequisites
Before using this module in your Ballerina application, you must obtain the necessary configuration to engage with Pinecone:

- Create a [Pinecone account](https://www.pinecone.io/start/)
- Create a Pinecone index through the [Pinecone Console](https://app.pinecone.io/)
- Obtain your API key from the Pinecone Console
- Get your index service URL from the Pinecone Console

## Quickstart
To use the `ai.pinecone` module in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module
Import the `ai.pinecone` module along with required AI modules.

```ballerina
import ballerinax/ai.pinecone;
```

### Step 2: Initialize the Vector Store
Here's how to initialize the Pinecone Vector Store:

```ballerina
import ballerina/ai;
import ballerinax/ai.pinecone;

// Basic initialization
ai:VectorStore vectorStore = check new pinecone:VectorStore(
    serviceUrl = "https://your-index-name.svc.region.pinecone.io", 
    apiKey = "your-pinecone-api-key"
);

ai:VectorStore vectorStore = check new pinecone:VectorStore(
    serviceUrl = "https://your-index-name.svc.region.pinecone.io",
    apiKey = "your-pinecone-api-key"
);
```

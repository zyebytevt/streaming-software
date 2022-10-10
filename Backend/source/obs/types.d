module obs.types;

import vibe.vibe;

enum OBSWebSocketOpCode
{
    hello = 0,
    identify = 1,
    identified = 2,
    reidentify = 3,
    event = 5,
    request = 6,
    requestResponse = 7,
    requestBatch = 8,
    requestBatchResponse = 9,
}

enum OBSEventSubscription
{
    none = 0,
    general = 1 << 0,
    config = 1 << 1,
    scenes = 1 << 2,
    inputs = 1 << 3,
    transitions = 1 << 4,
    filters = 1 << 5,
    outputs = 1 << 6,
    sceneItems = 1 << 7,
    mediaInputs = 1 << 8,
    vendors = 1 << 9,
    ui = 1 << 10,
    all = general | config | scenes | inputs | transitions | filters | outputs | sceneItems | mediaInputs | vendors | ui,
    inputVolumeMeters = 1 << 16,
    inputActiveStateChanged = 1 << 17,
    inputShowStateChanged = 1 << 18,
    sceneItemTransformChanged = 1 << 19,
}

enum OBSRequestStatusCode
{
    unknown = 0,
    noError = 10,
    success = 100,
    missingRequestType = 203,
    unknownRequestType = 204,
    genericError = 205,
    unsupportedRequestBatchExecutionType = 206,
    missingRequestField = 300,
    missingRequestData = 301,
    invalidRequestField = 400,
    invalidRequestFieldType = 401,
    requestFieldOutOfRange = 402,
    requestFieldEmpty = 403,
    tooManyRequestFields = 404,
    outputRunning = 500,
    outputNotRunning = 501,
    outputPaused = 502,
    outputNotPaused = 504,
    studioModeActive = 505,
    studioModeNotActive = 506,
    resourceNotFound = 600,
    resourceAlreadyExists = 601,
    invalidResourceType = 602,
    notEnoughResources = 603,
    invalidResourceState = 604,
    invalidInputKind = 605,
    resourceNotConfigurable = 606,
    invalidFilterKind = 607,
    resourceCreationFailed = 700,
    resourceActionFailed = 701,
    requestProcessingFailed = 702,
    cannotAct = 703,
}

struct OBSMessage
{
    OBSWebSocketOpCode op;
    Json d;
}

struct obsDataOpCode
{
    OBSWebSocketOpCode opCode;
}

@obsDataOpCode(OBSWebSocketOpCode.hello)
struct OBSMessageDataHello
{
    struct Authentication
    {
        string challenge;
        string salt;
    }

    string obsWebSocketVersion;
    int rpcVersion;
    @optional Authentication authentication;
}

@obsDataOpCode(OBSWebSocketOpCode.identify)
struct OBSMessageDataIdentify
{
    int rpcVersion;
    OBSEventSubscription eventSubscriptions = OBSEventSubscription.all;
    @optional string authentication;
}

@obsDataOpCode(OBSWebSocketOpCode.identified)
struct OBSMessageDataIdentified
{
    int negotiatedRpcVersion;
}

@obsDataOpCode(OBSWebSocketOpCode.reidentify)
struct OBSMessageDataReidentify
{
    OBSEventSubscription eventSubscriptions = OBSEventSubscription.all;
}

@obsDataOpCode(OBSWebSocketOpCode.event)
struct OBSMessageDataEvent
{
    string eventType;
    OBSEventSubscription eventIntent;
    @optional Json eventData;
}

@obsDataOpCode(OBSWebSocketOpCode.request)
struct OBSMessageDataRequest
{
    string requestType;
    string requestId;
    @optional Json requestData;
}

@obsDataOpCode(OBSWebSocketOpCode.requestResponse)
struct OBSMessageDataRequestResponse
{
    struct RequestStatus
    {
        bool result;
        OBSRequestStatusCode code;
        @optional string comment;
    }

    string requestType;
    string requestId;
    RequestStatus requestStatus;
    @optional Json responseData;
}
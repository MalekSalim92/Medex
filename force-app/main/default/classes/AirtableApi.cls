public with sharing class AirtableApi {
  public static List<AirtableWrapper.Records> getProducts() {
    return getResponse('Product');
  }

  private static List<AirtableWrapper.Records> getResponse(String tableName) {
    HttpResponse response = callAirtableApi(tableName);
    return parseResponse(response);
  }

  private static HttpResponse callAirtableApi(String tableName) {
    String tableId = AirtableSelector.getTableId(tableName);
    String path = AirtableSelector.getBasePath();
    String endpoint = path + tableId;
    HttpClient client = new HttpClient(
      Constants.AIRTABLE_NAMED_CREDENTIAL,
      endpoint
    );
    return client.get();
  }

  private static List<AirtableWrapper.Records> parseResponse(
    HttpResponse response
  ) {
    if (response.getStatusCode() != 200) {
      throw new AirtableException(
        'API Status code : ' + response.getStatusCode()
      );
    }

    AirtableWrapper data = (AirtableWrapper) JSON.deserialize(
      response.getBody(),
      AirtableWrapper.class
    );
    return data.records;
  }
}

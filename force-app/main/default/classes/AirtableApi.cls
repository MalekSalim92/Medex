public with sharing class AirtableApi {
  public static Map<String, Object> getProducts() {
    return getResponse('Product');
  }

  private static Map<String, Object> getResponse(String tableName) {
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

  private static Map<String, Object> parseResponse(HttpResponse response) {
    if (response.getStatusCode() != 200) {
      throw new AirtableException(
        'API Status code : ' + response.getStatusCode()
      );
    }

    return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
  }
}

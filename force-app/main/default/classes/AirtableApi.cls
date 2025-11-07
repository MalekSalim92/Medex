public with sharing class AirtableApi {
  public static AirtableWrapper getAirtableProducts(String offset) {
    HttpClient client = callAirtableApi('Product', offset);
    return parseResponse(client.get());
  }

  public static void upsertAirtableProducts(List<Product2> productsToUpsert) {
    HttpClient client = callAirtableApi('Product', null);
    String payload = buildPayload(productsToUpsert);
    client.setHeader('Content-Type', 'application/json').patch(payload);
  }

  private static String buildPayload(List<Product2> productsToUpsert) {
    List<Map<String, Object>> records = new List<Map<String, Object>>();
    for (Product2 product : productsToUpsert) {
      Map<String, String> fields = new Map<String, String>();
      fields.put('Name', product.Name);
      fields.put('Size', product.Size__c);
      fields.put('Color', product.Color__c);
      fields.put('Reference', product.Reference_Id__c);
      fields.put('Category', product.Category__c);
      fields.put('Discipline', product.Discipline__c);
      Map<String, Object> fieldsWrapper = new Map<String, Object>();
      fieldsWrapper.put('fields', fields);
      records.add(fieldsWrapper);
    }
    Map<String, Object> performUpsert = new Map<String, Object>();
    performUpsert.put('fieldsToMergeOn', new List<String>{ 'Reference' });

    Map<String, Object> payload = new Map<String, Object>();
    payload.put('performUpsert', performUpsert);
    payload.put('records', records);

    return JSON.serialize(payload);
  }

  private static HttpClient callAirtableApi(String tableName, String offset) {
    String tableId = MetadataSelector.getAirtableTableId(tableName);
    MetadataSelector.AirtableConfig cfg = MetadataSelector.getAirtableBasePath();
    String apiVersion = cfg.apiVersion;
    String basePath = cfg.url;
    String endpoint =
      '/' +
      apiVersion +
      '/' +
      basePath +
      '/' +
      tableId +
      '/?offset=' +
      offset;
    HttpClient client = new HttpClient(
      Constants.AIRTABLE_NAMED_CREDENTIAL,
      endpoint
    );
    return client;
  }

  private static AirtableWrapper parseResponse(HttpResponse response) {
    if (response.getStatusCode() != 200) {
      throw new AirtableException(
        'API Status code : ' + response.getStatusCode()
      );
    }

    AirtableWrapper data = (AirtableWrapper) JSON.deserialize(
      response.getBody(),
      AirtableWrapper.class
    );
    return data;
  }
}

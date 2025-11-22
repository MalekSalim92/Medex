public with sharing class AirtableApi {
  public static AirtableWrapper getAirtableProducts(String offset) {
    HttpClient client = callAirtableApi('Product', offset);
    return parseResponse(client.get());
  }

  public static void updateAirtableProducts(List<Product2> productsToUpdate) {
    HttpClient client = callAirtableApi('Product', '');
    String payload = buildPayload(productsToUpdate);
    System.debug(payload);
    client.setHeader('Content-Type', 'application/json').patch(payload);
  }

  public static void insertAirtableProducts(List<Product2> productsToInsert) {
    HttpClient client = callAirtableApi('Product', '');
    String payload = buildPayload(productsToInsert);
    System.debug(payload);
    HttpResponse response = client.setHeader('Content-Type', 'application/json')
      .post(payload);
      
  }

  private static String buildPayload(List<Product2> productsToUpsert) {
    List<Map<String, Object>> records = new List<Map<String, Object>>();
    Map<String, String> airtableToSalesforceMapping = MetadataSelector.getAirtableFieldsMappingByName();
    Map<String, Object> payload = new Map<String, Object>();

    for (Product2 product : productsToUpsert) {
      Map<String, Object> fields = new Map<String, Object>();
      for (String fieldName : airtableToSalesforceMapping.keySet()) {
        String salesforceFieldName = airtableToSalesforceMapping.get(fieldName);
        fields.put(fieldName, product.get(salesforceFieldName));
      }
      Map<String, Object> fieldsWrapper = new Map<String, Object>();
      if (product.Airtable_Id__c != null)
        fieldsWrapper.put('id', product.Airtable_Id__c);
      fieldsWrapper.put('fields', fields);
      records.add(fieldsWrapper);
      // Map<String, Object> performUpsert = new Map<String, Object>();
      // performUpsert.put('fieldsToMergeOn', new List<String>{ 'Reference' });
      // payload.put('performUpsert', performUpsert);

      System.debug('records ::::: ' + records);
    }

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
      throw new AirtableException( 'API Status code : ' + response.getStatusCode());
    }

    AirtableWrapper data = (AirtableWrapper) JSON.deserialize(
      response.getBody(),
      AirtableWrapper.class
    );
    return data;
  }
}

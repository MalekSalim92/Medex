public with sharing class ProductSelector {
  public static List<Product2> productsByIds(Set<Id> productIds) {
    return [
      SELECT
        Id,
        Name,
        Reference_Id__c,
        Discipline__c,
        Category__c,
        Airtable_Id__c,
        Size__c,
        Color__c
      FROM Product2
      WHERE Id IN :productIds
    ];
  }

  public static List<Product2> products() {
    return [
      SELECT Id, Airtable_Id__c
      FROM Product2
    ];
  }
}

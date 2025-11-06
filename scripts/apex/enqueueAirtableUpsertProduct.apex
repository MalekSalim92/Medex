List<Product2> productsToUpser = [
  SELECT
    Id,
    Name,
    Reference_Id__c,
    Discipline__c,
    Category__c,
    Size__c,
    Color__c
  FROM Product2
];

System.enqueueJob(new AirtableQueueable(productsToUpser, 0));

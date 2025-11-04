public with sharing class AirtableSelector {
  public static String getTableId(String tableName) {
    List<Airtable_Table__mdt> table = [
      SELECT DeveloperName, Table_Id__c
      FROM Airtable_Table__mdt
      WHERE DeveloperName = :tableName.toUpperCase()
      LIMIT 1
    ];
    if (table.isEmpty()) {
      throw new AirtableException('Table not found');
    }
    return table[0].Table_Id__c;
  }

  public static String getBasePath() {
    List<Airtable_Configuration__mdt> path = [
      SELECT DeveloperName, Base_Path__c
      FROM Airtable_Configuration__mdt
      WHERE DeveloperName = 'path'
      LIMIT 1
    ];
    if (path.isEmpty()) {
      throw new AirtableException('Path not found');
    }

    return path[0].Base_Path__c;
  }
}

/**
 * Created by malek on 2025-11-22.
 */

public with sharing class UnitOfWork {
    private Map<Schema.SObjectType,List<SObject>> newRecordsByType = new Map<Schema.SObjectType,List<SObject>>();
    private List<SObject> dirtyRecords = new List<SObject>();
    private List<SObject> deletedRecords = new List<SObject>();

// yooo
    private List<Schema.SObjectType> insertOrder = new List<SObjectType>{
            Account.SObjectType,
            Contact.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType
    };

    public void registerNew(SObject record){
        Schema.SObjectType objectType = record.getSObjectType();
        if(!newRecordsByType.containsKey(objectType)){
            newRecordsByType.put(objectType,new List<SObject>());
        }
        newRecordsByType.get(objectType).add(record);
    }

    public void registerNew(List<SObject> records){
        for(SObject record : records){
            registerNew(record);
        }
    }

    public void registerDirty(SObject record){
        dirtyRecords.add(record);
    }

    public void registerDirty(List<SObject> records){
        dirtyRecords.addAll(records);
    }

    public void registerDelete(SObject record){
        deletedRecords.add(record);
    }

    public void registerDelete(List<SObject> records){
        deletedRecords.addAll(records);
    }


    public void commitWork(){


        update dirtyRecords;
        delete dirtyRecords;

    }
}
public with sharing class TestDataFactory {
  public static List<Product2> createProducts() {
    List<Product2> products = new List<Product2>();

    List<String> disciplines = new List<String>{
      'BJJ',
      'Judo',
      'Karate',
      'Taekwondo',
      'Boxing',
      'MMA',
      'Muay Thai',
      'Kickboxing'
    };
    List<String> sizes = new List<String>{
      'XS',
      'S',
      'M',
      'L',
      'XL',
      'XXL',
      'Kids'
    };
    List<String> colors = new List<String>{ 'Black', 'Blue', 'White' };

    Map<String, List<String>> categoryProducts = new Map<String, List<String>>{
      'Apparel' => new List<String>{
        'Gi Uniform',
        'Rashguard',
        'Training Shorts',
        'T-Shirt'
      },
      'Protective Gear' => new List<String>{
        'Sparring Gloves',
        'Shin Guards',
        'Mouth Guard',
        'Head Gear'
      },
      'Weapons & Tools' => new List<String>{
        'Bo Staff',
        'Nunchaku',
        'Kicking Pads'
      },
      'Accessories' => new List<String>{
        'Gym Bag',
        'Water Bottle',
        'Protein Powder'
      }
    };

    for (String category : categoryProducts.keySet()) {
      for (String discipline : disciplines) {
        for (String productName : categoryProducts.get(category)) {
          // For items that don't need color/size variations
          if (
            category == 'Weapons & Tools' ||
            productName == 'Protein Powder'
          ) {
            products.add(
              createProduct(productName, discipline, category, null, null)
            );
          }
          // Belts only need size
          else if (category == 'Belts') {
            for (String size : sizes) {
              products.add(
                createProduct(productName, discipline, category, size, null)
              );
            }
          }
          // Everything else needs size and color
          else {
            for (String size : sizes) {
              for (String color : colors) {
                products.add(
                  createProduct(productName, discipline, category, size, color)
                );
              }
            }
          }
        }
      }
    }

    insert products;
    System.debug('Inserted ' + products.size() + ' product records.');
    return products;
  }

  public static void createWarehouses() {
    List<Warehouse__c> warehouses = new List<Warehouse__c>();

    List<String> cities = new List<String>{
      'Montreal',
      'Toronto',
      'Ottawa',
      'Vancouver'
    };

    for (String city : cities) {
      warehouses.add(new Warehouse__c(Name = city));
    }

    insert warehouses;
    System.debug('Inserted ' + warehouses.size() + ' warehouses records.');
  }

  public static void createInventories() {
    List<Inventory__c> inventories = new List<Inventory__c>();

    List<Warehouse__c> warehouses = [SELECT Id FROM Warehouse__c];
    List<Product2> products = [SELECT Id FROM Product2];
    final integer STRING_LENGTH = 3;
    final Decimal MIN = Math.pow(10, STRING_LENGTH - 1); //Returns 100
    final Decimal MAX = Math.pow(10, STRING_LENGTH) - 1; // Returns 999

    for (Product2 product : products) {
      for (Warehouse__c warehouse : warehouses) {
        inventories.add(
          new Inventory__c(
            Product__c = product.Id,
            Warehouse__c = warehouse.Id,
            Quantity__c = generateRandomQuantity(MIN, MAX)
          )
        );
      }
    }

    insert inventories;
    System.debug('Inserted ' + inventories.size() + ' inventories records.');
  }

  private static Decimal generateRandomQuantity(Decimal min, Decimal max) {
    return Math.round(Math.random() * (max - min) + min);
  }

  private static Product2 createProduct(
    String name,
    String discipline,
    String category,
    String size,
    String color
  ) {
    String formattedSize = size == null ? '' : '-' + size.toUpperCase();
    String formattedColor = color == null ? '' : '-' + color.toUpperCase();
    return new Product2(
      Name = name,
      Discipline__c = discipline,
      Category__c = category,
      Size__c = size,
      Color__c = color,
      Reference_Id__c = name.toUpperCase() +
        '-' +
        discipline.toUpperCase() +
        formattedSize +
        formattedColor,
      IsActive = true
    );
  }
}

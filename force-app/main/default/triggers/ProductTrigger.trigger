trigger ProductTrigger on Product2(
  before insert,
  after insert,
  after update,
  after delete
) {
  new ProductTriggerHandler().run();
}
